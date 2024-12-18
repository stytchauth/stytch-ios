import StytchCore

final class SMSOTPEnrollmentViewModel {
    let state: SMSOTPEnrollmentState

    init(
        state: SMSOTPEnrollmentState
    ) {
        self.state = state
    }
}

struct SMSOTPEnrollmentState {
    let configuration: StytchB2BUIClient.Configuration
}
