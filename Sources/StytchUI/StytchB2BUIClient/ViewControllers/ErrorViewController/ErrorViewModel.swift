import StytchCore

final class ErrorViewModel {
    let state: ErrorState

    init(
        state: ErrorState
    ) {
        self.state = state
    }
}

struct ErrorState {
    let configuration: StytchB2BUIClient.Configuration
}
