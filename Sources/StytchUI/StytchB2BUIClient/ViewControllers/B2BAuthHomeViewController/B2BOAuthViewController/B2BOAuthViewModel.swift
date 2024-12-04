import StytchCore

protocol B2BOAuthViewModelProtocol {
    func startOAuth(
        options: StytchB2BUIClient.B2BOAuthProviderOptions,
        thirdPartyClientForTesting: ThirdPartyB2BOAuthProviderProtocol? // this param is only used for testing
    ) async throws
}

final class B2BOAuthViewModel {
    let state: B2BOAuthState
    let oAuthProvider: B2BOAuthProviderProtocol

    init(
        state: B2BOAuthState,
        oAuthProvider: B2BOAuthProviderProtocol = StytchB2BClient.oauth
    ) {
        self.state = state
        self.oAuthProvider = oAuthProvider
    }
}

extension B2BOAuthViewModel: B2BOAuthViewModelProtocol {
    func startOAuth(
        options: StytchB2BUIClient.B2BOAuthProviderOptions,
        thirdPartyClientForTesting: ThirdPartyB2BOAuthProviderProtocol? = nil
    ) async throws {
        guard state.configuration.supportsOauth else {
            return
        }

        let webAuthenticationConfiguration = StytchB2BClient.OAuth.ThirdParty.WebAuthenticationConfiguration(
            loginRedirectUrl: state.configuration.redirectUrl,
            signupRedirectUrl: state.configuration.redirectUrl,
            organizationSlug: state.configuration.organizationSlug,
            customScopes: options.customScopes,
            providerParams: options.providerParams
        )
        let client = thirdPartyClientForTesting ?? options.provider.client
        let (token, _) = try await client.start(configuration: webAuthenticationConfiguration)

        let authenticateParameters = StytchB2BClient.OAuth.AuthenticateParameters(
            oauthToken: token,
            sessionDurationMinutes: state.configuration.sessionDurationMinutes
        )
        let response = try await oAuthProvider.authenticate(parameters: authenticateParameters)

        B2BAuthenticationManager.handleMFAReponse(b2bMFAAuthenticateResponse: response)
    }
}

struct B2BOAuthState {
    let configuration: StytchB2BUIClient.Configuration
}
