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
        Task { [weak self] in
            do {
                if self?.state.configuration.authFlowType == .discovery {
                    let parameters = StytchB2BClient.MagicLinks.Email.DiscoveryParameters(
                        emailAddress: emailAddress,
                        discoveryRedirectUrl: self?.state.configuration.redirectUrl,
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
                        redirectUrl: self?.state.configuration.redirectUrl
                    )
                }
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}

struct B2BEmailMagicLinksState {
    let configuration: StytchB2BUIClient.Configuration
}
