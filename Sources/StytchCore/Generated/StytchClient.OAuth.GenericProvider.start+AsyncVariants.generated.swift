// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.OAuth.GenericProvider {
    /// docs
    func start(parameters: StartParameters, completion: @escaping Completion<Void>) {
        Task {
            do {
                completion(.success(try await start(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// docs
    func start(parameters: StartParameters) -> AnyPublisher<Void, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await start(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
