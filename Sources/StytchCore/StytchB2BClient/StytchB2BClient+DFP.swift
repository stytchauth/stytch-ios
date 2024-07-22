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
            guard let publicToken = StytchB2BClient.instance.configuration?.publicToken else {
                throw StytchSDKError.B2BSDKNotConfigured
            }
            #if os(iOS)
            return await dfpClient.getTelemetryId(publicToken: publicToken)
            #else
            return ""
            #endif
        }
    }
}
