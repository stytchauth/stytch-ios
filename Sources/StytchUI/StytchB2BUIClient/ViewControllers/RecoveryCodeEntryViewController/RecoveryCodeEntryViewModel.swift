import StytchCore

final class RecoveryCodeEntryViewModel {
    let state: RecoveryCodeEntryState

    init(
        state: RecoveryCodeEntryState
    ) {
        self.state = state
    }
}

struct RecoveryCodeEntryState {
    let configuration: StytchB2BUIClient.Configuration
}
