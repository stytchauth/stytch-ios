import Foundation

final class PollingClient {
    typealias Task = (@escaping () -> Void, @escaping (Error) -> Void) -> Void

    private let _beginPollingIfNeeded: (PollingClient, @escaping Task, TimeInterval, UInt) -> Void

    private let _stopPolling: (PollingClient) -> Void

    private var retrier: Retrier?

    private var timer: Timer?

    init(beginPollingIfNeeded: @escaping (PollingClient, @escaping Task, TimeInterval, UInt) -> Void, stopPolling: @escaping (PollingClient) -> Void) {
        _beginPollingIfNeeded = beginPollingIfNeeded
        _stopPolling = stopPolling
    }

    func beginPollingIfNeeded(pollingInterval: TimeInterval, maxRetries: UInt, task: @escaping Task) {
        _beginPollingIfNeeded(self, task, pollingInterval, maxRetries)
    }

    func stopPolling() {
        _stopPolling(self)
    }
}

private extension DispatchQueue {
    static let sessionPolling: DispatchQueue = .init(label: "com.stytch.StytchCore.SessionPolling")
}

extension PollingClient {
    static let live: PollingClient = .init { client, task, pollingInterval, maxRetries in
        client.timer?.invalidate()
        client.retrier?.cancel()

        client.retrier = .init(maxRetries: maxRetries, queue: .sessionPolling, task: task)

        let timer = Timer(timeInterval: pollingInterval, repeats: true) { _ in
            client.retrier?.attempt()
        }

        client.timer = timer

        print("begin polling")
        RunLoop.main.add(timer, forMode: .common) // TODO: add callback to alert developer session has been updated
    } stopPolling: { client in
        client.timer?.invalidate()
        client.timer = nil
        client.retrier?.cancel()
        client.retrier = nil
    }
}

// Need way to cancel previous retries
final class Retrier {
    private let currentRetryValue: UInt
    private let maxRetries: UInt
    private let queue: DispatchQueue
    private var isCancelled: () -> Bool = { false }
    private var _isCancelled: Bool = false
    private var task: (@escaping () -> Void, @escaping (Error) -> Void) -> Void = { _, _ in }
    private var _next: Retrier?

    init(
        currentRetryValue: UInt = 0,
        maxRetries: UInt,
        queue: DispatchQueue,
        isCancelled: (() -> Bool)? = nil,
        task: @escaping (@escaping () -> Void, @escaping (Error) -> Void) -> Void
    ) {
        self.currentRetryValue = currentRetryValue
        self.maxRetries = maxRetries
        self.queue = queue
        self.isCancelled = isCancelled ?? { [weak self] in self?._isCancelled ?? false }
        self.task = task
    }

    deinit {
        print(#function)
    }

    func attempt(success: @escaping () -> Void = {}, failure: @escaping (Error) -> Void = { _ in }) {
        let failureWrapper: (Error) -> Void = { [weak self] error in
            guard let self = self, !self.isCancelled(), let next = self.next() else {
                failure(error)
                return
            }
            self._next = next
            next.attempt(success: success, failure: failure)
        }
        print("queueing: \(currentRetryValue)")
        let referenceDate = Current.date()
        let wrappedTask = { [weak self] in
            guard let self = self, !self.isCancelled() else { return }
            print("running task \(self.currentRetryValue) @ \(Current.date().timeIntervalSince(referenceDate))")
            self.task(success, failureWrapper)
        }
        if currentRetryValue == 0 {
            wrappedTask()
        } else {
            queue.asyncAfter(deadline: .now() + pow(2, Double(currentRetryValue - 1)), execute: wrappedTask)
        }
    }

    func cancel() {
        _isCancelled = true
    }

    private func next() -> Retrier? {
        guard currentRetryValue <= maxRetries, !isCancelled() else { return nil }

        return .init(currentRetryValue: currentRetryValue + 1, maxRetries: maxRetries, queue: queue, isCancelled: isCancelled, task: task)
    }
}
