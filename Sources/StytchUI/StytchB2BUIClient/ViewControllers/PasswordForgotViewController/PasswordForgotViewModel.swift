import StytchCore

protocol PasswordForgotViewModelDelegate: AnyObject {
    func didSendResetByEmailStart()
    func didSendEmailMagicLink()
    func didError(error: Error)
}

final class PasswordForgotViewModel {
    let state: PasswordForgotState
    weak var delegate: PasswordForgotViewModelDelegate?

    init(
        state: PasswordForgotState
    ) {
        self.state = state
    }

    func resetPassword(emailAddress: String) {
        MemberManager.updateMemberEmailAddress(emailAddress)

        guard let organizationId = OrganizationManager.organizationId else {
            delegate?.didError(error: StytchSDKError.noOrganziationId)
            return
        }

        Task {
            do {
                let member = try await AuthenticationOperations.searchMember(emailAddress: emailAddress, organizationId: organizationId)
                if member?.memberPasswordId != nil {
                    let parameters = StytchB2BClient.Passwords.ResetByEmailStartParameters(
                        organizationId: Organization.ID(rawValue: organizationId),
                        emailAddress: emailAddress,
                        resetPasswordUrl: state.configuration.redirectUrl,
                        locale: .en
                    )
                    _ = try await StytchB2BClient.passwords.resetByEmailStart(parameters: parameters)
                    delegate?.didSendResetByEmailStart()
                } else {
                    try await AuthenticationOperations.sendEmailMagicLinkIfPossible(emailAddress: emailAddress, organizationId: organizationId, redirectUrl: state.configuration.redirectUrl)
                    delegate?.didSendEmailMagicLink()
                }
            } catch {
                delegate?.didError(error: error)
            }
        }
    }
}

struct PasswordForgotState {
    let configuration: StytchB2BUIClient.Configuration
}
