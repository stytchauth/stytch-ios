import StytchCore

protocol OAuthViewModelDelegate {}

protocol OAuthViewModelProtocol {
    func startOAuth(provider: StytchUIClient.Configuration.OAuth.Provider) async throws
}

final class OAuthViewModel {
    var state: OAuthState
    let delegate: OAuthViewModelDelegate

    init(state: OAuthState, delegate: OAuthViewModelDelegate) {
        self.state = state
        self.delegate = delegate
    }
}

extension OAuthViewModel: OAuthViewModelProtocol {
    func startOAuth(provider: StytchUIClient.Configuration.OAuth.Provider) async throws {
        switch provider {
        case .apple:
            _ = try await StytchClient.oauth.apple.start(parameters: .init(sessionDuration: sessionDuration))
        case let .thirdParty(provider):
            let (token, _) = try await provider.client.start(
                parameters: .init(loginRedirectUrl: state.config.oauth!.loginRedirectUrl, signupRedirectUrl: state.config.oauth!.signupRedirectUrl)
            )
            _ = try await StytchClient.oauth.authenticate(parameters: .init(token: token, sessionDuration: sessionDuration))
        }
    }
}

struct OAuthState {
    let config: StytchUIClient.Configuration
}

private extension OAuthViewModel {
    var sessionDuration: Minutes {
        state.config.session?.sessionDuration ?? .defaultSessionDuration
    }
}

private extension StytchClient.OAuth.ThirdParty.Provider {
    var client: StytchClient.OAuth.ThirdParty {
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
