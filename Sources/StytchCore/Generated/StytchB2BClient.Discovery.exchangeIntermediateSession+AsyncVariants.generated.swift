// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.Discovery {
    /// Wraps Stytch's [exchange intermediate session](https://stytch.com/docs/b2b/api/exchange-intermediate-session) endpoint. This operation consumes the `intermediate_session_token`. If this method succeeds, the Member will be logged in, and granted an active session.
    func exchangeIntermediateSession(parameters: ExchangeIntermediateSessionParameters, completion: @escaping Completion<ExchangeIntermediateSessionResponse>) {
        Task {
            do {
                completion(.success(try await exchangeIntermediateSession(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Wraps Stytch's [exchange intermediate session](https://stytch.com/docs/b2b/api/exchange-intermediate-session) endpoint. This operation consumes the `intermediate_session_token`. If this method succeeds, the Member will be logged in, and granted an active session.
    func exchangeIntermediateSession(parameters: ExchangeIntermediateSessionParameters) -> AnyPublisher<ExchangeIntermediateSessionResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await exchangeIntermediateSession(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
