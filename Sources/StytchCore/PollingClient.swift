import Foundation

final class PollingClient {
    private let interval: TimeInterval
    private let maxRetries: UInt
    private let queue: DispatchQueue
    private let task: Task
    private var retrier: Retrier?
    private var timer: Timer?

    init(interval: TimeInterval, maxRetries: UInt, queue: DispatchQueue, task: @escaping Task) {
        self.interval = interval
        self.maxRetries = maxRetries
        self.queue = queue
        self.task = task
    }

    func beginPolling() {
        timer?.invalidate()
        retrier?.cancel()
        retrier = nil

        let timer = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.retrier?.cancel()
            self.retrier = .init(maxRetries: self.maxRetries, queue: self.queue, task: self.task)
            self.retrier?.attempt()
        }

        self.timer = timer

        RunLoop.main.add(timer, forMode: .common)
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
        private let task: Task

        init(maxRetries: UInt, queue: DispatchQueue, task: @escaping Task) {
            self.maxRetries = maxRetries
            self.queue = queue
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
            let wrappedTask = { [weak self] in
                guard let self = self, !self.isCancelled else { return }
                self.task(success, failureWrapper)
            }
            if currentRetryValue == 0 {
                wrappedTask()
            } else {
                queue.asyncAfter(deadline: .now() + pow(2, Double(currentRetryValue - 1)), execute: wrappedTask)
            }
        }

        func cancel() {
            isCancelled = true
        }
    }
}
