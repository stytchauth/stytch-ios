import Foundation

final class PollingClient {
    private let interval: TimeInterval
    private let maxRetries: UInt
    private let queue: DispatchQueue
    private let task: Task
    private var retryClient: RetryClient?
    private var timer: Timer?

    @Dependency(\.timer) private var createTimer

    init(
        interval: TimeInterval,
        maxRetries: UInt,
        queue: DispatchQueue,
        task: @escaping Task
    ) {
        self.interval = interval
        self.maxRetries = maxRetries
        self.queue = queue
        self.task = task
    }

    func start() {
        timer?.invalidate()
        retryClient?.cancel()
        retryClient = nil

        timer = createTimer(interval, .main) { [weak self] in
            guard let self = self else { return }
            self.retryClient?.cancel()
            self.retryClient = .init(maxRetries: self.maxRetries, queue: self.queue, task: self.task)
            self.retryClient?.attempt()
        }
    }

    func stop() {
        DispatchQueue.main.async { [weak self] in
            self?.timer?.invalidate()
            self?.timer = nil
            self?.retryClient?.cancel()
            self?.retryClient = nil
        }
    }
}

extension PollingClient {
    typealias Task = (@escaping () -> Void, @escaping (Error) -> Void) -> Void
}

private extension PollingClient {
    final class RetryClient {
        private var currentRetryValue: UInt = 0
        private let maxRetries: UInt
        private let queue: DispatchQueue
        private var isCancelled: Bool = false
        private let task: Task

        @Dependency(\.asyncAfter) private var asyncAfter

        init(
            maxRetries: UInt,
            queue: DispatchQueue,
            task: @escaping Task
        ) {
            self.maxRetries = maxRetries
            self.queue = queue
            self.task = task
        }

        func attempt(success: @escaping () -> Void = {}, failure: @escaping (Error) -> Void = { _ in }) {
            let failureWrapper: (Error) -> Void = { [weak self] error in
                if let error = error as? StytchAPIError, error.statusCode == 401 {
                    failure(error)
                    return
                }
                guard let self = self, !self.isCancelled, self.currentRetryValue < self.maxRetries else {
                    failure(error)
                    return
                }
                self.currentRetryValue += 1
                self.attempt(success: success, failure: failure)
            }
            // We'll set the due time to: 2 seconds from now * 2^n +/- jitter
            let delayForRetry: (UInt) -> DispatchTime = { .now() + 2 * pow(2, Double($0 - 1)) + Double.random(in: -0.0175...0.0175) }
            let wrappedTask = { [weak self] in
                guard let self = self, !self.isCancelled else { return }
                self.task(success, failureWrapper)
            }
            // On the first attempt, execute immediately
            if currentRetryValue == 0 {
                wrappedTask()
            } else {
                asyncAfter(queue, delayForRetry(currentRetryValue), wrappedTask)
            }
        }

        func cancel() {
            isCancelled = true
        }
    }
}
