import Foundation

struct DFPClient {
    var getTelemetryId: () async throws -> String?
    init(getTelemetryId: @escaping () async throws -> String?) {
        self.getTelemetryId = getTelemetryId
    }
}
