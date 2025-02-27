import StytchCore

final class SSODiscoveryMenuViewModel {
    let state: SSODiscoveryMenuState

    init(
        state: SSODiscoveryMenuState
    ) {
        self.state = state
    }
}

struct SSODiscoveryMenuState {
    let configuration: StytchB2BUIClient.Configuration
}
