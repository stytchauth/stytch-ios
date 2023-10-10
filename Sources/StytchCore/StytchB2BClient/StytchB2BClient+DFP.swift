#if os(iOS)
public extension StytchB2BClient {
    struct DFP {
        @Dependency(\.dfpClient) private var dfpClient
        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Returns a DFP Telemetry ID
        public func getTelemetryID() async throws -> String {
            guard let publicToken = StytchB2BClient.instance.configuration?.publicToken else { throw StytchError.clientNotConfigured }
            return await dfpClient.getTelemetryId(publicToken: publicToken)
        }
    }
}

public extension StytchB2BClient {
    static let dfp: DFP = .init()
}
#endif
