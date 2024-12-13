import StytchCore

final class PasswordResetViewModel {
    let state: PasswordResetState

    init(
        state: PasswordResetState
    ) {
        self.state = state
    }

    func resetPassword(newPassword: String) async throws {
        let response = try await StytchB2BClient.passwords.resetByEmail(
            parameters: .init(
                token: state.token,
                password: newPassword,
                locale: .en
            )
        )
        B2BAuthenticationManager.handlePrimaryMFAReponse(b2bMFAAuthenticateResponse: response)
    }

    func checkStrength(emailAddress: String?, password: String) async throws -> StytchB2BClient.Passwords.StrengthCheckResponse {
        try await StytchB2BClient.passwords.strengthCheck(parameters: .init(emailAddress: emailAddress, password: password))
    }
}

struct PasswordResetState {
    let configuration: StytchB2BUIClient.Configuration
    let token: String
    let email: String
}
