import StytchCore

final class SuccessViewModel {
    let state: SuccessState

    init(
        state: SuccessState
    ) {
        self.state = state
    }
}

struct SuccessState {
    let configuration: StytchB2BUIClient.Configuration
}
