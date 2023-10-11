// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.DFP {
    /// Returns a DFP Telemetry ID
    func getTelemetryID(completion: @escaping Completion<String>) {
        Task {
            do {
                completion(.success(try await getTelemetryID()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Returns a DFP Telemetry ID
    func getTelemetryID() -> AnyPublisher<String, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await getTelemetryID()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
