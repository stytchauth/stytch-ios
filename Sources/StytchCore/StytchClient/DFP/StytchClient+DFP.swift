public extension StytchClient {
    struct DFP {
        #if os(iOS)
        @Dependency(\.dfpClient) private var dfpClient
        #endif
        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Returns a DFP Telemetry ID
        public func getTelemetryID() async throws -> String {
            guard let publicToken = StytchClient.instance.configuration?.publicToken else {
                throw StytchSDKError.consumerSDKNotConfigured
            }
            guard let dfppaDomain = StytchClient.instance.configuration?.dfppaDomain else {
                throw StytchSDKError.consumerSDKNotConfigured
            }
            #if os(iOS)
            return await dfpClient.getTelemetryId(publicToken: publicToken, dfppaDomain: dfppaDomain)
            #else
            return ""
            #endif
        }
    }
}

public extension StytchClient {
    static let dfp: DFP = .init()
}
