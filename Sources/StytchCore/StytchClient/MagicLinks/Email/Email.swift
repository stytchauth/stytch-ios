public extension StytchClient.MagicLinks {
    /// The SDK provides methods to send and authenticate magic links that you can connect to your own UI.
    struct Email {
        let pathContext: Endpoint.Path

        init(pathContext: Endpoint.Path) {
            self.pathContext = pathContext.appendingPathComponent("email")
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps Stytch's email magic link [login_or_create](https://stytch.com/docs/api/log-in-or-create-user-by-email) endpoint. Requests an email magic link for a user to log in or create an account depending on the presence and/or status current account.
        public func loginOrCreate(parameters: Parameters, completion: @escaping Completion<BasicResponse>) {
            StytchClient.post(
                to: .init(path: pathContext.appendingPathComponent("login_or_create")),
                parameters: parameters,
                completion: completion
            )
        }
    }

    /// The interface for interacting with email magic links.
    var email: Email { .init(pathContext: pathContext) }
}
