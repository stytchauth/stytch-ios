import StytchCore

final class SSOViewModel {
    let state: SSOState

    init(
        state: SSOState
    ) {
        self.state = state
    }
}

struct SSOState {
    let configuration: StytchB2BUIClient.Configuration
}
