extension StytchClient {
    struct Bootstrap {
        let router: NetworkingRouter<BootstrapRoute>

        #if os(iOS)
        @Dependency(\.captcha) private var captcha
        #endif
        @Dependency(\.networkingClient) private var networkingClient

        public func fetch() async throws {
            guard let publicToken = StytchClient.instance.configuration?.publicToken else { throw StytchError.clientNotConfigured }
            let bootstrapData = try await router.get(route: .fetch(Path(rawValue: publicToken))) as BootstrapResponse
            #if os(iOS)
            if !bootstrapData.wrapped.captchaSettings.siteKey.isEmpty {
                try await captcha.setCaptchaClient(siteKey: bootstrapData.wrapped.captchaSettings.siteKey)
            }
            networkingClient.dfpEnabled = bootstrapData.wrapped.dfpProtectedAuthEnabled
            #endif
        }
    }
}

internal extension StytchClient {
    /// The interface for interacting with magic-links products.
    static var bootstrap: Bootstrap { .init(router: router.scopedRouter { $0.bootstrap }) }
}
