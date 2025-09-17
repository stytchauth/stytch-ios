import StytchCore

final class B2BOAuthViewModel {
    let state: B2BOAuthState

    init(
        state: B2BOAuthState
    ) {
        self.state = state
    }
}

extension B2BOAuthViewModel {
    func startOAuth(
        options: StytchB2BUIClient.B2BOAuthProviderOptions
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
        let (token, _) = try await options.provider.client.start(configuration: webAuthenticationConfiguration)

        let authenticateParameters = StytchB2BClient.OAuth.AuthenticateParameters(
            oauthToken: token,
            locale: state.configuration.locale
        )
        let response = try await StytchB2BClient.oauth.authenticate(parameters: authenticateParameters)

        B2BAuthenticationManager.handlePrimaryMFAReponse(b2bMFAAuthenticateResponse: response)
    }

    func startDiscoveryOAuth(
        options: StytchB2BUIClient.B2BOAuthProviderOptions
    ) async throws {
        guard state.configuration.supportsOauth else {
            return
        }

        let webAuthenticationConfiguration = StytchB2BClient.OAuth.ThirdParty.Discovery.WebAuthenticationConfiguration(
            discoveryRedirectUrl: state.configuration.redirectUrl,
            customScopes: options.customScopes,
            providerParams: options.providerParams
        )
        let (token, _) = try await options.provider.client.discovery.start(configuration: webAuthenticationConfiguration)

        let authenticateParameters = StytchB2BClient.OAuth.Discovery.DiscoveryAuthenticateParameters(discoveryOauthToken: token)
        let response = try await StytchB2BClient.oauth.discovery.authenticate(parameters: authenticateParameters)

        MemberManager.updateMemberEmailAddress(response.emailAddress)
        DiscoveryManager.updateDiscoveredOrganizations(newDiscoveredOrganizations: response.discoveredOrganizations)
    }
}

struct B2BOAuthState {
    let configuration: StytchB2BUIClient.Configuration
}
