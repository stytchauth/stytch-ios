import AuthenticationServices

struct AppleOAuthClient {
    private var authenticate: (@escaping (ASAuthorizationController) -> Void, String) async throws -> Result

    init(authenticate: @escaping (@escaping (ASAuthorizationController) -> Void, String) async throws -> Self.Result) {
        self.authenticate = authenticate
    }

    func authenticate(
        configureController: @escaping (ASAuthorizationController) -> Void,
        nonce: String
    ) async throws -> Result {
        try await authenticate(configureController, nonce)
    }
}

extension AppleOAuthClient {
    struct Result {
        let idToken: String
        let name: User.Name?
    }
}
