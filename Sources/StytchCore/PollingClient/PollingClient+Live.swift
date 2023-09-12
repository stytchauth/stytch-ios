import Foundation

extension PollingClient {
    // A polling client which tries to complete every 3 minutes, and will retry w/ exponential backoff upon errors, for up to a total of approximately 124 seconds.
    static let sessions: PollingClient = .init(interval: 180, maxRetries: 5, queue: .sessionsPolling) { onSuccess, onFailure in
        StytchClient.sessions.authenticate(parameters: .init()) { result in
            switch result {
            case .success:
                onSuccess()
            case let .failure(error):
                print("[DEBUG] >>> PollingClient Session refresh failed")
                onFailure(error)
            }
        }
    }

    // A polling client which tries to complete every 3 minutes, and will retry w/ exponential backoff upon errors, for up to a total of approximately 124 seconds.
    static let memberSessions: PollingClient = .init(interval: 180, maxRetries: 5, queue: .sessionsPolling) { onSuccess, onFailure in
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

private extension DispatchQueue {
    static let sessionsPolling: DispatchQueue = .init(label: "com.stytch.StytchCore.SessionsPolling")
}
