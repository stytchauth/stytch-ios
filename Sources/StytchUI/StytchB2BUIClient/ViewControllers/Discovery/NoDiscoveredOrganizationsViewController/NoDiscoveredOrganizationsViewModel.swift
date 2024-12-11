import StytchCore

final class NoDiscoveredOrganizationsViewModel {
    let state: NoDiscoveredOrganizationsState

    init(
        state: NoDiscoveredOrganizationsState
    ) {
        self.state = state
    }
}

struct NoDiscoveredOrganizationsState {
    let configuration: StytchB2BUIClient.Configuration
}
