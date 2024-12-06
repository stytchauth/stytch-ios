import StytchCore

final class TOTPEnrollmentViewModel {
    let state: TOTPEnrollmentState

    init(
        state: TOTPEnrollmentState
    ) {
        self.state = state
    }
}

struct TOTPEnrollmentState {
    let configuration: StytchB2BUIClient.Configuration
    let secret: String
}
