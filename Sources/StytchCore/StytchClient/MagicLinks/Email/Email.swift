public extension StytchClient.MagicLinks {
    // sourcery: TerminalInterface
    struct Email {
        let pathContext: String

        init(pathContext: String) {
            self.pathContext = String(pathContext.drop(while: { $0 == "/" })) + "/email"
        }

        // sourcery: AsyncVariants
        /// Wraps Stytch's email magiclink `login_or_create` endpoint. Requests an email magiclink for a user to
        /// either log in or create an account depending on the presence/status of their current account.
        func loginOrCreate(parameters: EmailParameters, completion: @escaping Completion<EmailResponse>) {
            StytchClient.instance.post(
                parameters: parameters,
                path: "\(pathContext)/login_or_create",
                completion: completion
            )
        }
    }
}
