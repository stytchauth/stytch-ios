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
        Task {
            guard let organizationId = OrganizationManager.organizationId else {
                completion(StytchSDKError.noOrganziationId)
                return
            }

            do {
                try await AuthenticationOperations.sendEmailMagicLink(
                    emailAddress: emailAddress,
                    organizationId: organizationId,
                    redirectUrl: state.configuration.redirectUrl
                )
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
