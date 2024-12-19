import StytchCore

final class CreateOrganizationsViewModel {
    let state: CreateOrganizationsState

    init(
        state: CreateOrganizationsState
    ) {
        self.state = state
    }
}

struct CreateOrganizationsState {
    let configuration: StytchB2BUIClient.Configuration
}
