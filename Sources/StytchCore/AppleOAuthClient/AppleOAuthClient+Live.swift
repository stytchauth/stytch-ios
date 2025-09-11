import AuthenticationServices

extension AppleOAuthClient {
    static let live: Self = .init { configureController, nonce in
        let provider: ASAuthorizationAppleIDProvider = .init()
        let request = provider.createRequest()
        request.requestedScopes = [.email, .fullName]
        request.nonce = nonce

        let controller = ASAuthorizationController(authorizationRequests: [request])
        configureController(controller)
        let delegate: Self.Delegate = await .init()
        controller.delegate = delegate

        return try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                delegate.continuation = continuation
                controller.performRequests()
            }
        }
    }
}

extension AppleOAuthClient {
    private final class Delegate: NSObject, ASAuthorizationControllerDelegate {
        var continuation: CheckedContinuation<Result, Error>?

        func authorizationController(controller _: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                continuation?.resume(throwing: StytchSDKError.invalidAuthorizationCredential)
                return
            }
            guard let idToken = credential.identityToken, let token = String(data: idToken, encoding: .utf8) else {
                continuation?.resume(throwing: StytchSDKError.missingAuthorizationCredentialIDToken)
                return
            }
            var name: User.Name?
            if credential.fullName?.givenName != nil || credential.fullName?.familyName != nil {
                name = .init(firstName: credential.fullName?.givenName, lastName: credential.fullName?.familyName)
            }
            continuation?.resume(returning: .init(idToken: token, name: name))
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
