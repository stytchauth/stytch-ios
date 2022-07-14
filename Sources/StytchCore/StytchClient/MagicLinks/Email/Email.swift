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
            do {
                let (codeChallenge, codeChallengeMethod) = try StytchClient.generateAndStorePKCE()

                StytchClient.post(
                    to: .init(path: pathContext.appendingPathComponent("login_or_create")),
                    parameters: CodeChallengedParameters(
                        codeChallenge: codeChallenge,
                        codeChallengeMethod: codeChallengeMethod,
                        wrapped: parameters
                    ),
                    completion: completion
                )
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// The interface for interacting with email magic links.
    var email: Email { .init(pathContext: pathContext) }
}

//private extension StytchClient.MagicLinks.Email {
    struct CodeChallengedParameters<T: Encodable>: Encodable {
        private enum CodingKeys: String, CodingKey { case codeChallenge, codeChallengeMethod }

        let codeChallenge: String
        let codeChallengeMethod: String
        let wrapped: T

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try wrapped.encode(to: encoder)

            try container.encode(codeChallenge, forKey: .codeChallenge)
            try container.encode(codeChallengeMethod, forKey: .codeChallengeMethod)
        }
    }
//}
