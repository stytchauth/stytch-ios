// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.Passwords.Discovery {
    /// 
    func resetByEmailStart(parameters: ResetByEmailStartParameters, completion: @escaping Completion<BasicResponse>) {
        Task {
            do {
                completion(.success(try await resetByEmailStart(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// 
    func resetByEmailStart(parameters: ResetByEmailStartParameters) -> AnyPublisher<BasicResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await resetByEmailStart(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
