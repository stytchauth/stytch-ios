public extension StytchClient.MagicLinks {
    /// The interface type for email magic links.
    struct Email {
        let pathContext: Endpoint.Path

        init(pathContext: Endpoint.Path) {
            self.pathContext = pathContext.appendingPathComponent("email")
        }

        // sourcery: AsyncVariants
        /**
          Wraps Stytch's email magic link [login_or_create](https://stytch.com/docs/api/log-in-or-create-user-by-email) endpoint. Requests an email magiclink for a user to log in or create an account depending on the presence and/or status of their current account.
         */
        public func loginOrCreate(parameters: Parameters, completion: @escaping Completion<BasicResponse>) {
            StytchClient.post(
                to: .init(
                    path: pathContext.appendingPathComponent("login_or_create"),
                    queryItems: [.init(name: "type", value: "em")]
                ),
                parameters: parameters,
                completion: completion
            )
        }
    }

    /// The interface implementation for email magic links.
    var email: Email { .init(pathContext: pathContext) }
}
