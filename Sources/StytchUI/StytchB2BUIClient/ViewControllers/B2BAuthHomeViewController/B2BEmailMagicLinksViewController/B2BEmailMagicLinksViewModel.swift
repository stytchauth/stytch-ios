import StytchCore

final class B2BEmailMagicLinksViewModel {
    let state: B2BEmailMagicLinksState

    init(
        state: B2BEmailMagicLinksState
    ) {
        self.state = state
    }

    func sendEmailMagicLink(
        emailAddress: String,
        completion: @escaping (Error?) -> Void
    ) {
        MemberManager.updateMemberEmailAddress(emailAddress)
        StytchB2BUIClient.startLoading()
        Task {
            do {
                if state.configuration.computedAuthFlowType == .discovery {
                    let parameters = StytchB2BClient.MagicLinks.Email.DiscoveryParameters(
                        emailAddress: emailAddress,
                        discoveryRedirectUrl: state.configuration.redirectUrl,
                        locale: .en
                    )
                    _ = try await StytchB2BClient.magicLinks.email.discoverySend(parameters: parameters)
                } else {
                    guard let organizationId = OrganizationManager.organizationId else {
                        completion(StytchSDKError.noOrganziationId)
                        return
                    }

                    try await AuthenticationOperations.sendEmailMagicLink(
                        emailAddress: emailAddress,
                        organizationId: organizationId,
                        redirectUrl: state.configuration.redirectUrl
                    )
                }
                completion(nil)
                StytchB2BUIClient.stopLoading()
            } catch {
                completion(error)
                StytchB2BUIClient.stopLoading()
            }
        }
    }
}

struct B2BEmailMagicLinksState {
    let configuration: StytchB2BUIClient.Configuration
}
