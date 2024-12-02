import StytchCore

final class B2BEmailMagicLinksViewModel {
    let state: B2BEmailMagicLinksState

    init(
        state: B2BEmailMagicLinksState
    ) {
        self.state = state
    }
}

struct B2BEmailMagicLinksState {
    let configuration: StytchB2BUIClient.Configuration
}
