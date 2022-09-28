import AuthenticationServices

struct AppleOAuthClient {
    private var authenticate: (ASAuthorizationControllerPresentationContextProviding?, String) async throws -> Result

    init(authenticate: @escaping (ASAuthorizationControllerPresentationContextProviding?, String) async throws -> AppleOAuthClient.Result) {
        self.authenticate = authenticate
    }

    func authenticate(
        presentationContextProvider: ASAuthorizationControllerPresentationContextProviding? = nil,
        nonce: String
    ) async throws -> Result {
        try await authenticate(presentationContextProvider, nonce)
    }
}

extension AppleOAuthClient {
    struct Result {
        let idToken: String
        let name: StytchClient.OAuth.Apple.Name
    }
}
