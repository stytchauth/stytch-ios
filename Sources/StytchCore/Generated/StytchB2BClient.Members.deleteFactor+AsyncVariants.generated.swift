// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.Members {
    /// Deletes, by id, an existing authentication factor associated with the current member.
    func deleteFactor(_ factor: Member.AuthenticationFactor, completion: @escaping Completion<MemberResponse>) {
        Task {
            do {
                completion(.success(try await deleteFactor(factor)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Deletes, by id, an existing authentication factor associated with the current member.
    func deleteFactor(_ factor: Member.AuthenticationFactor) -> AnyPublisher<MemberResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await deleteFactor(factor)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
