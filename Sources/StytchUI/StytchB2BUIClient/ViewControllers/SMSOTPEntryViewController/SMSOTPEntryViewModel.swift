import StytchCore

final class SMSOTPEntryViewModel {
    let state: SMSOTPEntryState

    init(
        state: SMSOTPEntryState
    ) {
        self.state = state
    }
}

struct SMSOTPEntryState {
    let configuration: StytchB2BUIClient.Configuration
}
