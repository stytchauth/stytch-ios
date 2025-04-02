import Foundation

public extension StytchB2BClient {
    static let dfp: DFP = .init()
}

public extension StytchB2BClient {
    struct DFP {
        #if os(iOS)
        @Dependency(\.dfpClient) private var dfpClient
        #endif
        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Returns a DFP Telemetry ID
        public func getTelemetryID() async throws -> String {
            #if os(iOS)
            let telemetryId = await dfpClient.getTelemetryId()
            return telemetryId
            #else
            return ""
            #endif
        }
    }
}
