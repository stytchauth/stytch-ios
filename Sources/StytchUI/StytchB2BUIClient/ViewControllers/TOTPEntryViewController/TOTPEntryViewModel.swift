import StytchCore

final class TOTPEntryViewModel {
    let state: TOTPEntryState

    init(
        state: TOTPEntryState
    ) {
        self.state = state
    }
}

struct TOTPEntryState {
    let configuration: StytchB2BUIClient.Configuration
}
