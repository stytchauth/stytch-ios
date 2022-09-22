// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.OAuth.Apple {
    /// docs
    func start(presentationContextProvider: ASAuthorizationControllerPresentationContextProviding? = nil, completion: @escaping Completion<AuthenticateResponseType>) {
        Task {
            do {
                completion(.success(try await start(presentationContextProvider: presentationContextProvider)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// docs
    func start(presentationContextProvider: ASAuthorizationControllerPresentationContextProviding? = nil) -> AnyPublisher<AuthenticateResponseType, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await start(presentationContextProvider: presentationContextProvider)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
