import Foundation

public extension StytchB2BClient {
    static var magicLinks: MagicLinks { .init(router: router.scopedRouter { $0.magicLinks }) }

    struct MagicLinks {
        let router: NetworkingRouter<MagicLinksRoute>

        public func authenticate(parameters: AuthenticateParameters) async throws -> B2BAuthenticateResponse {
            guard let codeVerifier: String = try? Current.keychainClient.get(.emlPKCECodeVerifier) else { throw StytchError.pckeNotAvailable }

            return try await router.post(
                to: .authenticate,
                parameters: CodeVerifierParameters(codingPrefix: "pkce", codeVerifier: codeVerifier, wrapped: parameters)
            )
        }

        public struct AuthenticateParameters: Codable {
            private enum CodingKeys: String, CodingKey {
                case sessionDuration = "sessionDurationMinutes"
                case token = "magicLinksToken"
            }

            let token: String
            let sessionDuration: Minutes
        }
    }
}

public extension StytchB2BClient.MagicLinks {
    var email: Email { .init(router: router.scopedRouter { $0.email }) }

    struct Email {
        let router: NetworkingRouter<StytchB2BClient.MagicLinksRoute.EmailRoute>

        public func loginOrSignup(parameters: Parameters) async throws -> BasicResponse {
            let (codeChallenge, codeChallengeMethod) = try StytchB2BClient.generateAndStorePKCE(keychainItem: .emlPKCECodeVerifier)

            return try await router.post(
                to: .loginOrSignup,
                parameters: CodeChallengedParameters(
                    codingPrefix: "pkce",
                    codeChallenge: codeChallenge,
                    codeChallengeMethod: codeChallengeMethod,
                    wrapped: parameters
                )
            )
        }

        public struct Parameters: Codable {
            let organizationId: Organization.ID
            let email: String
            let loginRedirectUrl: URL?
            let signupRedirectUrl: URL?
            let loginTemplateId: String?
            let signupTemplateId: String?
        }
    }
}
