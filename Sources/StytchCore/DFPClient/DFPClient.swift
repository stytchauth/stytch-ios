import Foundation

struct DFPClient {
    var getTelemetryId: (String) async throws -> String

    init(getTelemetryId: @escaping (String) async throws -> String) {
        self.getTelemetryId = getTelemetryId
    }
}
