import StytchCore

final class PasswordForgotViewModel {
    let state: PasswordForgotState

    init(
        state: PasswordForgotState
    ) {
        self.state = state
    }
}

struct PasswordForgotState {
    let configuration: StytchB2BUIClient.Configuration
}
