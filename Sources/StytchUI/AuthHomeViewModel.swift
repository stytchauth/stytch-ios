protocol AuthHomeViewModelDelegate {}

protocol AuthHomeViewModelProtocol {}

final class AuthHomeViewModel {
    let state: AuthHomeState
    let delegate: AuthHomeViewModelDelegate

    init(state: AuthHomeState, delegate: AuthHomeViewModelDelegate) {
        self.state = state
        self.delegate = delegate
    }
}

extension AuthHomeViewModel: AuthHomeViewModelProtocol {}

struct AuthHomeState {
    let bootstrap: Bootstrap
    let config: StytchUIClient.Configuration
}
