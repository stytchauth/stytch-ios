import StytchCore

final class EmailConfirmationViewModel {
    let state: EmailConfirmationState

    init(
        state: EmailConfirmationState
    ) {
        self.state = state
    }
}

struct EmailConfirmationState {
    let configuration: StytchB2BUIClient.Configuration
}
