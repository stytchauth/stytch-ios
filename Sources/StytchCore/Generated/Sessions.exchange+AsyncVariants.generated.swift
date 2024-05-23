// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension Sessions {
    /// Use this endpoint to exchange a Member's existing session for another session in a different Organization.
    func exchange(parameters: ExchangeParameters, completion: @escaping Completion<B2BAuthenticateResponse>) {
        Task {
            do {
                completion(.success(try await exchange(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Use this endpoint to exchange a Member's existing session for another session in a different Organization.
    func exchange(parameters: ExchangeParameters) -> AnyPublisher<B2BAuthenticateResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await exchange(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
