import StytchCore

final class SSODiscoveryFallbackViewModel {
    let state: SSODiscoveryFallbackState

    init(
        state: SSODiscoveryFallbackState
    ) {
        self.state = state
    }
}

struct SSODiscoveryFallbackState {
    let configuration: StytchB2BUIClient.Configuration
}
