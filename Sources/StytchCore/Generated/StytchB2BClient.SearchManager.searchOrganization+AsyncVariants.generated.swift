// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.SearchManager {
    /// Search for an organization by its slug
    func searchOrganization(searchOrganizationParameters: SearchOrganizationParameters, completion: @escaping Completion<SearchOrganizationResponse>) {
        Task {
            do {
                completion(.success(try await searchOrganization(searchOrganizationParameters: searchOrganizationParameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Search for an organization by its slug
    func searchOrganization(searchOrganizationParameters: SearchOrganizationParameters) -> AnyPublisher<SearchOrganizationResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await searchOrganization(searchOrganizationParameters: searchOrganizationParameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
