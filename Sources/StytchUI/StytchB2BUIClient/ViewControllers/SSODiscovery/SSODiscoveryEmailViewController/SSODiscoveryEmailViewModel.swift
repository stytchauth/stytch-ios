import StytchCore

protocol SSODiscoveryEmailViewModelDelegate: AnyObject {
    func ssoDiscoveryDidDirectAuthenticate()
    func ssoDiscoveryDidFindZeroConnections()
    func ssoDiscoveryDidFindMultipleConnections()
    func ssoDiscoveryDidError(error: Error)
}

final class SSODiscoveryEmailViewModel {
    let state: SSODiscoveryEmailState
    weak var delegate: SSODiscoveryEmailViewModelDelegate?

    init(
        state: SSODiscoveryEmailState
    ) {
        self.state = state
    }

    func startSSODiscovery(emailAddress: String) {
        StytchB2BUIClient.startLoading()
        MemberManager.updateMemberEmailAddress(emailAddress)
        Task {
            do {
                let ssoActiveConnections = try await SSODiscoveryManager.fetchSSODiscoveryConnections(emailAddress)
                StytchB2BUIClient.stopLoading()
                if ssoActiveConnections.count == 1 {
                    try await AuthenticationOperations.startSSO(
                        configuration: state.configuration,
                        connectionId: ssoActiveConnections.first?.connectionId
                    )
                    delegate?.ssoDiscoveryDidDirectAuthenticate()
                } else if ssoActiveConnections.count > 1 {
                    delegate?.ssoDiscoveryDidFindMultipleConnections()
                } else {
                    delegate?.ssoDiscoveryDidFindZeroConnections()
                }
            } catch {
                StytchB2BUIClient.stopLoading()
                delegate?.ssoDiscoveryDidError(error: error)
            }
        }
    }
}

struct SSODiscoveryEmailState {
    let configuration: StytchB2BUIClient.Configuration
}
