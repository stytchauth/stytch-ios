import StytchCore

final class BiometricsRegistrationViewModel {
    let state: BiometricsRegistrationState

    init(
        state: BiometricsRegistrationState
    ) {
        self.state = state
    }
}

struct BiometricsRegistrationState {
    let config: StytchUIClient.Configuration
}
