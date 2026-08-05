import AuthenticationServices

#if !os(watchOS)
@available(macOS 12.0, iOS 16.0, tvOS 16.0, *)
struct PasskeysClient {
    var registerCredential: (String, Data, String, User.ID, [Data]) async throws -> ASAuthorizationPublicKeyCredentialRegistration
    var assertCredential: (String, Data, [Data], StytchClient.Passkeys.AuthenticateParameters.RequestBehavior) async throws -> ASAuthorizationPublicKeyCredentialAssertion

    func registerCredential(domain: String, challenge: Data, username: String, userId: User.ID, excludedCredentialIds: [Data]) async throws -> ASAuthorizationPublicKeyCredentialRegistration {
        try await registerCredential(domain, challenge, username, userId, excludedCredentialIds)
    }

    func assertCredential(
        domain: String,
        challenge: Data,
        allowedCredentialIds: [Data],
        requestBehavior: StytchClient.Passkeys.AuthenticateParameters.RequestBehavior
    ) async throws -> ASAuthorizationPublicKeyCredentialAssertion {
        try await assertCredential(domain, challenge, allowedCredentialIds, requestBehavior)
    }
}
#endif
