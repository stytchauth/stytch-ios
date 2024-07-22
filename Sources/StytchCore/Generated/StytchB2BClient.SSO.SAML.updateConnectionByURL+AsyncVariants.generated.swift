// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

#if !os(watchOS)
public extension StytchB2BClient.SSO.SAML {
    func updateConnectionByURL(parameters: UpdateConnectionByURLParameters, completion: @escaping Completion<SAMLConnectionResponse>) {
        Task {
            do {
                completion(.success(try await updateConnectionByURL(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func updateConnectionByURL(parameters: UpdateConnectionByURLParameters) -> AnyPublisher<SAMLConnectionResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await updateConnectionByURL(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
#endif
