import StytchCore

protocol OAuthViewModelProtocol {
    func startOAuth(
        provider: StytchUIClient.Configuration.OAuth.Provider,
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
        provider: StytchUIClient.Configuration.OAuth.Provider,
        thirdPartyClientForTesting: ThirdPartyOAuthProviderProtocol? = nil
    ) async throws {
        switch provider {
        case .apple:
            let response = try await appleOauthProvider.start(parameters: .init(sessionDuration: sessionDuration))
            StytchUIClient.onAuthCallback?(response)
        case let .thirdParty(provider):
            if let oauth = state.config.oauth {
                let (token, _) = try await (thirdPartyClientForTesting ?? provider.client).start(
                    configuration: .init(loginRedirectUrl: oauth.loginRedirectUrl, signupRedirectUrl: oauth.signupRedirectUrl)
                )
                let response = try await oAuthProvider.authenticate(parameters: .init(token: token, sessionDuration: sessionDuration))
                StytchUIClient.onAuthCallback?(response)
            }
        }
    }
}

struct OAuthState {
    let config: StytchUIClient.Configuration
}

extension OAuthViewModel {
    var sessionDuration: Minutes {
        state.config.session?.sessionDuration ?? .defaultSessionDuration
    }
}

extension StytchClient.OAuth.ThirdParty.Provider {
    var client: ThirdPartyOAuthProviderProtocol {
        switch self {
        case .amazon:
            return StytchClient.oauth.amazon
        case .bitbucket:
            return StytchClient.oauth.bitbucket
        case .coinbase:
            return StytchClient.oauth.coinbase
        case .discord:
            return StytchClient.oauth.discord
        case .facebook:
            return StytchClient.oauth.facebook
        case .figma:
            return StytchClient.oauth.figma
        case .github:
            return StytchClient.oauth.github
        case .gitlab:
            return StytchClient.oauth.gitlab
        case .google:
            return StytchClient.oauth.google
        case .linkedin:
            return StytchClient.oauth.linkedin
        case .microsoft:
            return StytchClient.oauth.microsoft
        case .salesforce:
            return StytchClient.oauth.salesforce
        case .slack:
            return StytchClient.oauth.slack
        case .snapchat:
            return StytchClient.oauth.snapchat
        case .spotify:
            return StytchClient.oauth.spotify
        case .tiktok:
            return StytchClient.oauth.tiktok
        case .twitch:
            return StytchClient.oauth.twitch
        case .twitter:
            return StytchClient.oauth.twitter
        case .yahoo:
            return StytchClient.oauth.yahoo
        }
    }
}
