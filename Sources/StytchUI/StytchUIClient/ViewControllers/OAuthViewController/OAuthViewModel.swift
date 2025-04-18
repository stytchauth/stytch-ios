import StytchCore

protocol OAuthViewModelProtocol {
    func startOAuth(
        provider: StytchUIClient.OAuthProvider,
        thirdPartyClientForTesting: ThirdPartyOAuthProviderProtocol? // this param is only used for testing
    ) async throws
}

final class OAuthViewModel {
    let state: OAuthState
    let appleOauthProvider: AppleOAuthProviderProtocol
    let oAuthProvider: OAuthProviderProtocol

    init(
        state: OAuthState,
        appleOAuthProvider: AppleOAuthProviderProtocol = StytchClient.oauth.apple,
        oAuthProvider: OAuthProviderProtocol = StytchClient.oauth
    ) {
        self.state = state
        appleOauthProvider = appleOAuthProvider
        self.oAuthProvider = oAuthProvider
    }
}

extension OAuthViewModel: OAuthViewModelProtocol {
    func startOAuth(
        provider: StytchUIClient.OAuthProvider,
        thirdPartyClientForTesting: ThirdPartyOAuthProviderProtocol? = nil
    ) async throws {
        guard state.config.supportsOauth else { return }
        switch provider {
        case .apple:
            let response = try await appleOauthProvider.start(parameters: .init(sessionDuration: state.config.sessionDurationMinutes))
        case let .thirdParty(provider):
            let (token, _) = try await (thirdPartyClientForTesting ?? provider.client).start(
                configuration: .init(loginRedirectUrl: state.config.redirectUrl, signupRedirectUrl: state.config.redirectUrl)
            )
            let response = try await oAuthProvider.authenticate(parameters: .init(token: token, sessionDurationMinutes: state.config.sessionDurationMinutes))
        }
    }
}

struct OAuthState {
    let config: StytchUIClient.Configuration
}
