extension StytchClient.MagicLinks {
    // sourcery: TerminalInterface
    public struct Email {
        let pathContext: String

        init(pathContext: String) {
            self.pathContext = String(pathContext.drop(while: { $0 == "/" })) + "/email"
        }

        // sourcery: AsyncVariants
        /// loginOrCreate
        /// Does some stuff, as named.
        /// - Parameters:
        ///   - parameters: Email parameters
        ///   - completion: Completion block
        func loginOrCreate(parameters: EmailParameters, completion: @escaping Completion<EmailResponse>) {
            StytchClient.instance.post(
                parameters: parameters,
                path: "\(pathContext)/login_or_create",
                completion: completion
            )
        }
    }
}
