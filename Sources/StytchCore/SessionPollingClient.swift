import Foundation

final class SessionPollingClient {
    private let _beginPollingIfNeeded: (SessionPollingClient) -> Void

    private let _stopPolling: (SessionPollingClient) -> Void

    private var timer: Timer?

    private var taskId: UUID?

    init(beginPollingIfNeeded: @escaping (SessionPollingClient) -> Void, stopPolling: @escaping (SessionPollingClient) -> Void) {
        self._beginPollingIfNeeded = beginPollingIfNeeded
        self._stopPolling = stopPolling
    }

    func beginPollingIfNeeded() {
        _beginPollingIfNeeded(self)
    }

    func stopPolling() {
        _stopPolling(self)
    }
}

private extension DispatchQueue {
    static let sessionPolling: DispatchQueue = .init(label: "com.stytch.StytchCore.SessionPolling")
}

extension SessionPollingClient {
    static let live: SessionPollingClient = .init { client in
        client.timer?.invalidate()
        client.taskId = Current.uuid()
        let task: (UInt, @escaping () -> Void, @escaping (Error) -> Void) -> Void = { currentAttempt, onSuccess, onFailure in
            print("current attempt:", currentAttempt, Current.date())
            DispatchQueue.sessionPolling.asyncAfter(deadline: .now() + pow(2, Double(currentAttempt))) { [weak client, taskId = client.taskId] in
                guard client?.taskId == taskId else {
                    print("not same task")
                    return
                }
                print("authenticating")
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

        let timer = Timer(
            timeInterval: 30, // 180 // 3 minutes
            repeats: true
        ) { timer in
            Retrier(currentRetryValue: 0, maxRetries: 5, task: task)() {} failure: { _ in }
        }

        client.timer = timer

        RunLoop.main.add(timer, forMode: .common) // TODO: add callback to alert developer session has been updated
    } stopPolling: { client in
        client.timer?.invalidate()
        client.timer = nil
    }
}

// Need way to cancel previous retries
struct Retrier {
    let currentRetryValue: UInt
    let maxRetries: UInt
    let task: (UInt, @escaping () -> Void, @escaping (Error) -> Void) -> Void

    func callAsFunction(success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        let failureWrapper: (Error) -> Void = { error in
            // do we have retries left? if yes, call retry again
            // if not, report error
            if currentRetryValue <= maxRetries {
                Retrier(currentRetryValue: currentRetryValue + 1, maxRetries: maxRetries, task: task)(success: success, failure: failure)
            } else {
                failure(error)
            }
        }
        task(currentRetryValue, success, failureWrapper)
    }
}

