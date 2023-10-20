import AuthenticationServices

#if !os(watchOS)
@available(macOS 12.0, iOS 16.0, tvOS 16.0, *)
struct PasskeysClient {
    var registerCredential: (String, Data, String, User.ID) async throws -> ASAuthorizationPublicKeyCredentialRegistration
    var assertCredential: (String, Data, StytchClient.Passkeys.AuthenticateParameters.RequestBehavior) async throws -> ASAuthorizationPublicKeyCredentialAssertion

    func registerCredential(domain: String, challenge: Data, username: String, userId: User.ID) async throws -> ASAuthorizationPublicKeyCredentialRegistration {
        try await registerCredential(domain, challenge, username, userId)
    }

    func assertCredential(
        domain: String,
        challenge: Data,
        requestBehavior: StytchClient.Passkeys.AuthenticateParameters.RequestBehavior
    ) async throws -> ASAuthorizationPublicKeyCredentialAssertion {
        try await assertCredential(domain, challenge, requestBehavior)
    }
}
#endif
