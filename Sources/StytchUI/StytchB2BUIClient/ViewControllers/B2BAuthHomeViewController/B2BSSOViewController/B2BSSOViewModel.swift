import StytchCore

final class SSOViewModel {
    let state: SSOState

    init(
        state: SSOState
    ) {
        self.state = state
    }

    func startSSO(connectionId: String?) async throws {
        guard state.configuration.supportsSSO else {
            return
        }

        let webAuthenticationConfiguration = StytchB2BClient.SSO.WebAuthenticationConfiguration(
            connectionId: connectionId,
            loginRedirectUrl: state.configuration.redirectUrl,
            signupRedirectUrl: state.configuration.redirectUrl
        )
        let (token, _) = try await StytchB2BClient.sso.start(configuration: webAuthenticationConfiguration)

        let authenticateParameters = StytchB2BClient.SSO.AuthenticateParameters(
            token: token,
            sessionDuration: state.configuration.sessionDurationMinutes,
            locale: .en
        )
        let response = try await StytchB2BClient.sso.authenticate(parameters: authenticateParameters)
        B2BAuthenticationManager.handlePrimaryMFAReponse(b2bMFAAuthenticateResponse: response)
    }
}

struct SSOState {
    let configuration: StytchB2BUIClient.Configuration
}
