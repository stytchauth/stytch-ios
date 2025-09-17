import StytchCore

final class PasswordResetViewModel {
    let state: PasswordResetState

    init(
        state: PasswordResetState
    ) {
        self.state = state
    }

    func resetPassword(newPassword: String) async throws {
        if state.configuration.computedAuthFlowType == .discovery {
            try await discoveryResetPassword(newPassword)
        } else {
            try await organizationResetPassword(newPassword)
        }
    }

    func organizationResetPassword(_ newPassword: String) async throws {
        let response = try await StytchB2BClient.passwords.resetByEmail(
            parameters: .init(
                passwordResetToken: state.token,
                password: newPassword,
                locale: state.configuration.locale
            )
        )
        B2BAuthenticationManager.handlePrimaryMFAReponse(b2bMFAAuthenticateResponse: response)
    }

    func discoveryResetPassword(_ newPassword: String) async throws {
        let response = try await StytchB2BClient.passwords.discovery.resetByEmail(
            parameters: .init(
                passwordResetToken: state.token,
                password: newPassword,
                locale: state.configuration.locale
            )
        )
        DiscoveryManager.updateDiscoveredOrganizations(newDiscoveredOrganizations: response.discoveredOrganizations)
    }

    func checkStrength(emailAddress: String?, password: String) async throws -> StytchB2BClient.Passwords.StrengthCheckResponse {
        try await StytchB2BClient.passwords.strengthCheck(parameters: .init(emailAddress: emailAddress, password: password))
    }
}

struct PasswordResetState {
    let configuration: StytchB2BUIClient.Configuration
    let token: String
    let email: String?
}
