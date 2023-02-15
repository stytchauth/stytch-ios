public extension StytchB2BClient {
    static var sessions: Sessions<B2BAuthenticateResponse> { .init(router: router.scopedRouter { $0.sessions }) }
}
