public extension StytchClient.MagicLinks {
    struct Email {
        let pathContext: Path

        init(pathContext: Path) {
            self.pathContext = pathContext.appendingPathComponent("email")
        }

        // sourcery: AsyncVariants
        /// Wraps Stytch's email magiclink `login_or_create` endpoint. Requests an email magiclink for a user to
        /// either log in or create an account depending on the presence/status of their current account.
        func loginOrCreate(parameters: EmailParameters, completion: @escaping Completion<BasicResponse>) {
            StytchClient.post(
                parameters: parameters,
                path: pathContext.appendingPathComponent("login_or_create"),
                completion: completion
            )
        }
    }
}
