import StytchCore

final class MFAEnrollmentSelectionViewModel {
    let state: MFAEnrollmentSelectionState

    init(
        state: MFAEnrollmentSelectionState
    ) {
        self.state = state
    }
}

struct MFAEnrollmentSelectionState {
    let configuration: StytchB2BUIClient.Configuration
}
