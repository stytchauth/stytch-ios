// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.Sessions {
    /// Wraps Stytch's [revoke](https://stytch.com/docs/api/session-revoke) Session endpoint and revokes the user's current session. This method should be used to log out a user. A successful revocation will terminate session-refresh polling.
    func revoke(completion: @escaping Completion<BasicResponse>) {
        Task {
            do {
                completion(.success(try await revoke()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Wraps Stytch's [revoke](https://stytch.com/docs/api/session-revoke) Session endpoint and revokes the user's current session. This method should be used to log out a user. A successful revocation will terminate session-refresh polling.
    func revoke() -> AnyPublisher<BasicResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await revoke()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
