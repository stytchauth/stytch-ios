import StytchCore

// B2BPasswordsViewModel and B2BPasswordsViewModelDelegate are shared between the home screen passwords form and the passwords authenticate screen

protocol B2BPasswordsViewModelDelegate: AnyObject {
    func didAuthenticateWithPassword()
    func didSendEmailMagicLink()
    func didError(error: Error)
}

final class B2BPasswordsViewModel {
    let state: B2BPasswordsState
    weak var delegate: B2BPasswordsViewModelDelegate?

    init(
        state: B2BPasswordsState
    ) {
        self.state = state
    }

    func authenticateWithPasswordIfPossible(
        emailAddress: String,
        password: String
    ) {
        MemberManager.updateMemberEmailAddress(emailAddress)

        guard let organizationId = OrganizationManager.organizationId else {
            delegate?.didError(error: StytchSDKError.noOrganziationId)
            return
        }

        Task { [weak self] in
            do {
                let member = try? await AuthenticationOperations.searchMember(emailAddress: emailAddress, organizationId: organizationId)
                if member?.memberPasswordId != nil {
                    let parameters = StytchB2BClient.Passwords.AuthenticateParameters(
                        organizationId: Organization.ID(rawValue: organizationId),
                        emailAddress: emailAddress,
                        password: password,
                        locale: .en
                    )
                    let response = try await StytchB2BClient.passwords.authenticate(parameters: parameters)
                    B2BAuthenticationManager.handleMFAReponse(b2bMFAAuthenticateResponse: response)
                    self?.delegate?.didAuthenticateWithPassword()
                } else {
                    try await AuthenticationOperations.sendEmailMagicLinkIfPossible(
                        emailAddress: emailAddress,
                        organizationId: organizationId,
                        redirectUrl: self?.state.configuration.redirectUrl
                    )
                    self?.delegate?.didSendEmailMagicLink()
                }
            } catch {
                self?.delegate?.didError(error: error)
            }
        }
    }
}

struct B2BPasswordsState {
    let configuration: StytchB2BUIClient.Configuration
}
