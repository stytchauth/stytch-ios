protocol AuthHomeViewModelDelegate {}

protocol AuthHomeViewModelProtocol {}

final class AuthHomeViewModel {
    let state: AuthHomeState

    init(state: AuthHomeState) {
        self.state = state
    }
}

extension AuthHomeViewModel: AuthHomeViewModelProtocol {}

struct AuthHomeState {
    let bootstrap: Bootstrap
    let config: StytchUIClient.Configuration
}
