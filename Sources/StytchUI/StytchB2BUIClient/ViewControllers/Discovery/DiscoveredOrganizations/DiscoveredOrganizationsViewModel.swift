import StytchCore

final class DiscoveredOrganizationsViewModel {
    let state: DiscoveredOrganizationsState

    init(
        state: DiscoveredOrganizationsState
    ) {
        self.state = state
    }
}

struct DiscoveredOrganizationsState {
    let configuration: StytchB2BUIClient.Configuration
}
