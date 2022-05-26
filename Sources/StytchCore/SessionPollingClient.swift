import Foundation

final class PollingClient {
    typealias Task = (@escaping () -> Void, @escaping (Error) -> Void) -> Void

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

        let timer = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.retrier?.cancel()
            self.retrier = .init(maxRetries: self.maxRetries, queue: self.queue, task: self.task)
            self.retrier?.attempt()
        }

        self.timer = timer

//        print("begin polling")
        RunLoop.main.add(timer, forMode: .common)
    }

    func stopPolling() {
        timer?.invalidate()
        timer = nil
        retrier?.cancel()
        retrier = nil
    }
}

private extension DispatchQueue {
    static let sessionPolling: DispatchQueue = .init(label: "com.stytch.StytchCore.SessionPolling")
}

// TODO: add callback to alert developer session has been updated

extension PollingClient {
    static let sessionPolling: PollingClient = .init(interval: 180, maxRetries: 5, queue: .sessionPolling) { onSuccess, onFailure in
        StytchClient.sessions.authenticate(parameters: .init()) { result in
            switch result {
            case .success:
                onSuccess()
            case let .failure(error):
                onFailure(error)
            }
        }
    }
}

final class Retrier {
    typealias Task = (_ onSuccess: @escaping () -> Void, _ onFailure: @escaping (Error) -> Void) -> Void

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
//        print("queueing: \(currentRetryValue)")
//        let referenceDate = Current.date()
        let wrappedTask = { [weak self] in
            guard let self = self, !self.isCancelled else { return }
//            print("running task \(self.currentRetryValue) @ \(Current.date().timeIntervalSince(referenceDate))")
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
