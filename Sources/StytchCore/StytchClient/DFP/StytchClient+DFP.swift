#if os(iOS)
public extension StytchClient {
    struct DFP {
        @Dependency(\.dfpClient) private var dfpClient
        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Returns a DFP Telemetry ID
        public func getTelemetryID() async throws -> String {
            guard let publicToken = StytchClient.instance.configuration?.publicToken else { throw StytchError.clientNotConfigured }
            return await dfpClient.getTelemetryId(publicToken: publicToken)
        }
    }
}

public extension StytchClient {
    static let dfp: DFP = .init()
}
#endif
