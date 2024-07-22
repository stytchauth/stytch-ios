// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.Organizations.Members {
    /// Deletes a authentication factor from the currently authenticated member.
    func deleteFactor(factor: Organization.MemberAuthenticationFactor, completion: @escaping Completion<OrganizationMemberResponse>) {
        Task {
            do {
                completion(.success(try await deleteFactor(factor: factor)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Deletes a authentication factor from the currently authenticated member.
    func deleteFactor(factor: Organization.MemberAuthenticationFactor) -> AnyPublisher<OrganizationMemberResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await deleteFactor(factor: factor)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
