import StytchCore

final class PasswordResetViewModel {
    let state: PasswordResetState

    init(
        state: PasswordResetState
    ) {
        self.state = state
    }
}

struct PasswordResetState {
    let configuration: StytchB2BUIClient.Configuration
    let token: String
    let email: String
}
