import StytchCore

final class B2BPasswordsHomeViewModel {
    let state: B2BPasswordsHomeState

    init(
        state: B2BPasswordsHomeState
    ) {
        self.state = state
    }
}

struct B2BPasswordsHomeState {
    let configuration: StytchB2BUIClient.Configuration
}
