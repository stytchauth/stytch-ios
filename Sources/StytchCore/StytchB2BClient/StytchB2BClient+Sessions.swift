public extension StytchB2BClient {
    /// The interface for interacting with sessions products.
    static var sessions: Sessions<B2BAuthenticateResponse> { .init(router: router.scopedRouter { $0.sessions }) }
}

public extension Sessions {
    // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
    /// Use this endpoint to exchange a Member's existing session for another session in a different Organization.
    func exchange(parameters: ExchangeParameters) async throws -> B2BAuthenticateResponse {
        try await router.post(to: .exchange, parameters: parameters)
    }
}

public extension Sessions {
    /// The dedicated parameters type for session `exchange` calls.
    struct ExchangeParameters: Codable {
        /// The ID of the organization that the new session should belong to.
        public let organizationID: String
        /// The duration, in minutes, for the requested session. Defaults to 30 minutes.
        public let sessionDurationMinutes: Minutes
        /// The locale will be used if an OTP code is sent to the member's phone number as part of a secondary authentication requirement.
        public let locale: String?

        public init(organizationID: String, sessionDurationMinutes: Minutes = .defaultSessionDuration, locale: String? = nil) {
            self.organizationID = organizationID
            self.sessionDurationMinutes = sessionDurationMinutes
            self.locale = locale
        }
    }
}
