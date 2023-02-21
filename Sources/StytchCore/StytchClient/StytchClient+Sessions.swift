public extension StytchClient {
    /// The interface for interacting with sessions products.
    static var sessions: Sessions<AuthenticateResponse> { .init(router: router.scopedRouter { $0.sessions }) }
}
