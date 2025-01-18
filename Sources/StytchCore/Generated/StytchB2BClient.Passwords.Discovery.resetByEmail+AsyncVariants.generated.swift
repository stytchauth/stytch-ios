// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.Passwords.Discovery {
    /// 
    func resetByEmail(parameters: ResetByEmailParameters, completion: @escaping Completion<StytchB2BClient.DiscoveryAuthenticateResponse>) {
        Task {
            do {
                completion(.success(try await resetByEmail(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// 
    func resetByEmail(parameters: ResetByEmailParameters) -> AnyPublisher<StytchB2BClient.DiscoveryAuthenticateResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await resetByEmail(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
