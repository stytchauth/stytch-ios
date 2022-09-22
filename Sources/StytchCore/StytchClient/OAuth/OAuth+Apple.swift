import AuthenticationServices

enum AppleRoute: RouteType {
    case authenticate

    var path: Path {
        switch self {
        case .authenticate:
            return "authenticate" // TODO: - confirm what the path should actually be
        }
    }
}

public extension StytchClient.OAuth {
    /// docs
    struct Apple {
        let router: NetworkingRouter<AppleRoute>

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// docs
        public func start(parameters: StartParameters) async throws -> AuthenticateResponseType {
            let nonce = try Current.cryptoClient.dataWithRandomBytesOfCount(32)
            let idToken = try await Current.appleOAuthClient.authenticate(
                presentationContextProvider: parameters.presentationContextProvider,
                nonce: Current.cryptoClient.sha256(nonce).base64EncodedString()
            )
            return try await router.post(
                to: .authenticate,
                parameters: AuthenticateParameters(nonce: nonce, idToken: idToken)
            ) as AuthenticateResponse
        }
    }
}

public extension StytchClient.OAuth.Apple {
    struct StartParameters {
        let presentationContextProvider: ASAuthorizationControllerPresentationContextProviding?

        public init(
            presentationContextProvider: ASAuthorizationControllerPresentationContextProviding? = nil
        ) {
            self.presentationContextProvider = presentationContextProvider
        }
    }
}

extension StytchClient.OAuth.Apple {
    struct AuthenticateParameters: Codable {
        let nonce: Data
        let idToken: Data
    }
}

extension StytchClient.Environment {
    // FIXME: - remove hack
    var appleOAuthClient: AppleOAuthClient { .instance }
}

final class AppleOAuthClient: NSObject, ASAuthorizationControllerDelegate {
    // FIXME: - remove hack
    static let instance: AppleOAuthClient = .init()

    private var continuation: CheckedContinuation<Data, Error>?

    func authenticate(presentationContextProvider: ASAuthorizationControllerPresentationContextProviding? = nil, nonce: String) async throws -> Data {
        let provider: ASAuthorizationAppleIDProvider = .init()
        let request = provider.createRequest()
        request.requestedScopes = [.email, .fullName]
        request.nonce = nonce

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.presentationContextProvider = presentationContextProvider
        controller.delegate = self

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            controller.performRequests()
        }
    }

    func authorizationController(controller _: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: StytchError.oauthCredentialInvalid)
            return
        }
        guard let token = credential.identityToken else {
            continuation?.resume(throwing: StytchError.oauthCredentialMissingIdToken)
            return
        }
        continuation?.resume(returning: token)
    }

    func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
    }
}
