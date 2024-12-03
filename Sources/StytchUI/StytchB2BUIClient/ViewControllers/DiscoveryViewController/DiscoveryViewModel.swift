import StytchCore

final class DiscoveryViewModel {
    let state: DiscoveryState

    init(
        state: DiscoveryState
    ) {
        self.state = state
    }
}

struct DiscoveryState {
    let configuration: StytchB2BUIClient.Configuration
}
