import StytchCore

final class RecoveryCodeSaveViewModel {
    let state: RecoveryCodeSaveState

    init(
        state: RecoveryCodeSaveState
    ) {
        self.state = state
    }
}

struct RecoveryCodeSaveState {
    let configuration: StytchB2BUIClient.Configuration
}
