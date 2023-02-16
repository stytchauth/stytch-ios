public extension StytchB2BClient {
    /// The interface for interacting with sessions products.
    static var sessions: Sessions<B2BAuthenticateResponse> { .init(router: router.scopedRouter { $0.sessions }) }
}
