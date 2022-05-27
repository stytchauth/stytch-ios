import Foundation

final class PollingClient {
    private let interval: TimeInterval
    private let maxRetries: UInt
    private let queue: DispatchQueue
    private let onInterval: (PollingClient, TimeInterval, @escaping () -> Void) -> Void
    private let task: Task
    private var retrier: Retrier?
    private var timer: Timer?

    init(
        interval: TimeInterval,
        maxRetries: UInt,
        queue: DispatchQueue,
        onInterval: @escaping (PollingClient, TimeInterval, @escaping () -> Void) -> Void = { client, interval, task in
            let timer = Timer(timeInterval: interval, repeats: true, block: { _ in task() })
            client.timer = timer
            RunLoop.main.add(timer, forMode: .common)
        },
        task: @escaping Task
    ) {
        self.interval = interval
        self.maxRetries = maxRetries
        self.queue = queue
        self.onInterval = onInterval
        self.task = task
    }

    func beginPolling() {
        timer?.invalidate()
        retrier?.cancel()
        retrier = nil

        onInterval(self, interval) { [weak self] in
            guard let self = self else { return }
            self.retrier?.cancel()
            self.retrier = .init(maxRetries: self.maxRetries, queue: self.queue, task: self.task)
            self.retrier?.attempt()
        }
    }

    func stopPolling() {
        timer?.invalidate()
        timer = nil
        retrier?.cancel()
        retrier = nil
    }
}

extension PollingClient {
    typealias Task = (@escaping () -> Void, @escaping (Error) -> Void) -> Void
}

private extension PollingClient {
    final class Retrier {
        private var currentRetryValue: UInt = 0
        private let maxRetries: UInt
        private let queue: DispatchQueue
        private var isCancelled: Bool = false
        private let asyncAfter: (DispatchQueue, DispatchTime, @escaping () -> Void) -> Void
        private let task: Task

        init(
            maxRetries: UInt,
            queue: DispatchQueue,
            asyncAfter: @escaping (DispatchQueue, DispatchTime, @escaping () -> Void) -> Void = { $0.asyncAfter(deadline: $1, execute: $2) },
            task: @escaping Task
        ) {
            self.maxRetries = maxRetries
            self.queue = queue
            self.asyncAfter = asyncAfter
            self.task = task
        }

        func attempt(success: @escaping () -> Void = {}, failure: @escaping (Error) -> Void = { _ in }) {
            let failureWrapper: (Error) -> Void = { [weak self] error in
                guard let self = self, !self.isCancelled, self.currentRetryValue < self.maxRetries else {
                    failure(error)
                    return
                }
                self.currentRetryValue += 1
                self.attempt(success: success, failure: failure)
            }
            // We'll set the due time to: 2 seconds from now * 2^n +/- jitter
            let delay: (UInt) -> DispatchTime = { .now() + 2 * pow(2, Double($0 - 1)) + Double.random(in: (-0.0175...0.0175)) }
            let wrappedTask = { [weak self] in
                guard let self = self, !self.isCancelled else { return }
                self.task(success, failureWrapper)
            }
            if currentRetryValue == 0 {
                wrappedTask()
            } else {
                asyncAfter(queue, delay(currentRetryValue), wrappedTask)
            }
        }

        func cancel() {
            isCancelled = true
        }
    }
}