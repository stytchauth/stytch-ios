import StytchCore

// B2BPasswordsViewModel and B2BPasswordsViewModelDelegate are shared between the home screen passwords form and the authentication screen.

protocol B2BPasswordsViewModelDelegate: AnyObject {
    func didAuthenticate()
    func didDiscoveryAuthenticate()
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
        if state.configuration.computedAuthFlowType == .discovery {
            discoveryAuthenticateWithPasswordIfPossible(emailAddress: emailAddress, password: password)
        } else {
            organizationAuthenticateWithPasswordIfPossible(emailAddress: emailAddress, password: password)
        }
    }

    func discoveryAuthenticateWithPasswordIfPossible(
        emailAddress: String,
        password: String
    ) {
        StytchB2BUIClient.startLoading()
        Task {
            do {
                let parameters = StytchB2BClient.Passwords.Discovery.AuthenticateParameters(emailAddress: emailAddress, password: password)
                let response = try await StytchB2BClient.passwords.discovery.authenticate(parameters: parameters)
                DiscoveryManager.updateDiscoveredOrganizations(newDiscoveredOrganizations: response.discoveredOrganizations)
                delegate?.didDiscoveryAuthenticate()
                StytchB2BUIClient.stopLoading()
            } catch {
                delegate?.didError(error: error)
                StytchB2BUIClient.stopLoading()
            }
        }
    }

    func organizationAuthenticateWithPasswordIfPossible(
        emailAddress: String,
        password: String
    ) {
        guard let organizationId = OrganizationManager.organizationId else {
            delegate?.didError(error: StytchSDKError.noOrganziationId)
            return
        }

        StytchB2BUIClient.startLoading()

        Task {
            do {
                let member = try? await AuthenticationOperations.searchMember(emailAddress: emailAddress)
                if member != nil {
                    let parameters = StytchB2BClient.Passwords.AuthenticateParameters(
                        organizationId: Organization.ID(rawValue: organizationId),
                        emailAddress: emailAddress,
                        password: password,
                        locale: state.configuration.locale
                    )
                    let response = try await StytchB2BClient.passwords.authenticate(parameters: parameters)
                    B2BAuthenticationManager.handlePrimaryMFAReponse(b2bMFAAuthenticateResponse: response)
                    delegate?.didAuthenticate()
                } else {
                    try await AuthenticationOperations.sendEmailMagicLinkIfPossible(
                        configuration: state.configuration,
                        emailAddress: emailAddress
                    )
                    delegate?.didSendEmailMagicLink()
                }
                StytchB2BUIClient.stopLoading()
            } catch {
                delegate?.didError(error: error)
                StytchB2BUIClient.stopLoading()
            }
        }
    }
}

struct B2BPasswordsState {
    let configuration: StytchB2BUIClient.Configuration
}
