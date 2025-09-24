import Foundation

extension PollingClient {
    // A polling client which tries to complete every 3 minutes, and will retry w/ exponential backoff upon errors, for up to a total of approximately 124 seconds.
    static let sessions: PollingClient = .init(interval: 180, maxRetries: 5, queue: .sessionsPolling) { onSuccess, onFailure in
        let authenticateParameters: StytchClient.Sessions.AuthenticateParameters
        if StytchClient.stytchClientConfiguration?.enableAutomaticSessionExtension == true {
            authenticateParameters = .init(sessionDurationMinutes: StytchClient.defaultSessionDuration)
        } else {
            authenticateParameters = .init(sessionDurationMinutes: nil)
        }

        StytchClient.sessions.authenticate(parameters: authenticateParameters) { result in
            switch result {
            case .success:
                onSuccess()
            case let .failure(error):
                onFailure(error)
            }
        }
    }

    // A polling client which tries to complete every 3 minutes, and will retry w/ exponential backoff upon errors, for up to a total of approximately 124 seconds.
    static let memberSessions: PollingClient = .init(interval: 180, maxRetries: 5, queue: .sessionsPolling) { onSuccess, onFailure in
        let authenticateParameters: StytchB2BClient.Sessions.AuthenticateParameters
        if StytchB2BClient.stytchClientConfiguration?.enableAutomaticSessionExtension == true {
            authenticateParameters = .init(sessionDurationMinutes: StytchB2BClient.defaultSessionDuration)
        } else {
            authenticateParameters = .init(sessionDurationMinutes: nil)
        }

        StytchB2BClient.sessions.authenticate(parameters: authenticateParameters) { result in
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
