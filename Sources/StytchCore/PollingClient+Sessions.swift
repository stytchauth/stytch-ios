import Foundation

extension PollingClient {
    static let sessions: PollingClient = .init(interval: 180, maxRetries: 5, queue: .sessionsPolling) { onSuccess, onFailure in
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
