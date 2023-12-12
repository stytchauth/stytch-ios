import AuthenticationServices

extension AppleOAuthClient {
    static let live: Self = .init { configureController, nonce in
        let provider: ASAuthorizationAppleIDProvider = .init()
        let request = provider.createRequest()
        request.requestedScopes = [.email, .fullName]
        request.nonce = nonce

        let controller = ASAuthorizationController(authorizationRequests: [request])
        configureController(controller)
        let delegate: Self.Delegate = .init()
        controller.delegate = delegate

        return try await withCheckedThrowingContinuation { continuation in
            delegate.continuation = continuation
            controller.performRequests()
        }
    }
}

extension AppleOAuthClient {
    private final class Delegate: NSObject, ASAuthorizationControllerDelegate {
        var continuation: CheckedContinuation<Result, Error>?

        func authorizationController(controller _: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                continuation?.resume(throwing: StytchSDKError.oauthCredentialInvalid)
                return
            }
            guard let idToken = credential.identityToken, let token = String(data: idToken, encoding: .utf8) else {
                continuation?.resume(throwing: StytchSDKError.oauthCredentialMissingIdToken)
                return
            }

            continuation?.resume(returning: .init(idToken: token, name: .init(credential.fullName)))
        }

        func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
            continuation?.resume(throwing: error)
        }
    }
}

private extension StytchClient.OAuth.Apple.Name {
    init(_ components: PersonNameComponents?) {
        self.init(firstName: components?.givenName, lastName: components?.familyName)
    }
}
