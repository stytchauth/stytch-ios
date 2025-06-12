import Foundation

public extension StytchClient {
    static let dfp: DFP = .init()
}

public extension StytchClient {
    struct DFP {
        #if canImport(StytchDFP)
        @Dependency(\.dfpClient) private var dfpClient
        #endif
        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Returns a DFP Telemetry ID
        public func getTelemetryID() async throws -> String {
            #if canImport(StytchDFP)
            let telemetryId = await dfpClient.getTelemetryId()
            return telemetryId
            #else
            return ""
            #endif
        }
    }
}
