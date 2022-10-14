import AuthenticationServices

@available(macOS 12.0, iOS 16.0, *)
struct PasskeysClient {
    var registerCredential: (String, Data, String, String) async throws -> ASAuthorizationPublicKeyCredentialRegistration
    var assertCredential: (String, Data, StytchClient.Passkeys.AuthenticateParameters.RequestBehavior) async throws -> ASAuthorizationPublicKeyCredentialAssertion

    func registerCredential(domain: String, challenge: Data, userName: String, userId: String) async throws -> ASAuthorizationPublicKeyCredentialRegistration {
        try await registerCredential(domain, challenge, userName, userId)
    }

    func assertCredential(
        domain: String,
        challenge: Data,
        requestBehavior: StytchClient.Passkeys.AuthenticateParameters.RequestBehavior
    ) async throws -> ASAuthorizationPublicKeyCredentialAssertion {
        try await assertCredential(domain, challenge, requestBehavior)
    }
}
