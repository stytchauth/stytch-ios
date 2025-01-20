import StytchCore

protocol PasswordForgotViewModelDelegate: AnyObject {
    func didSendResetByEmailStart()
    func didSendDiscoveryResetByEmailStart()
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
        if state.configuration.computedAuthFlowType == .discovery {
            discoveryResetPasswordByEmail(emailAddress)
        } else {
            organizationResetPasswordByEmail(emailAddress)
        }
    }

    func organizationResetPasswordByEmail(_ emailAddress: String) {
        guard let organizationId = OrganizationManager.organizationId else {
            delegate?.didError(error: StytchSDKError.noOrganziationId)
            return
        }

        Task {
            do {
                let member = try await AuthenticationOperations.searchMember(emailAddress: emailAddress, organizationId: organizationId)
                if let memberPasswordId = member?.memberPasswordId, memberPasswordId.isEmpty == false {
                    let parameters = StytchB2BClient.Passwords.ResetByEmailStartParameters(
                        organizationId: Organization.ID(rawValue: organizationId),
                        emailAddress: emailAddress,
                        loginUrl: state.configuration.redirectUrl,
                        resetPasswordUrl: state.configuration.redirectUrl,
                        resetPasswordExpiration: state.configuration.passwordOptions?.resetPasswordExpirationMinutes,
                        resetPasswordTemplateId: state.configuration.passwordOptions?.resetPasswordTemplateId
                    )
                    _ = try await StytchB2BClient.passwords.resetByEmailStart(parameters: parameters)
                    delegate?.didSendResetByEmailStart()
                } else {
                    try await AuthenticationOperations.sendEmailMagicLinkIfPossible(
                        configuration: state.configuration,
                        emailAddress: emailAddress,
                        organizationId: organizationId,
                        redirectUrl: state.configuration.redirectUrl
                    )
                    delegate?.didSendEmailMagicLink()
                }
            } catch {
                delegate?.didError(error: error)
            }
        }
    }

    func discoveryResetPasswordByEmail(_ emailAddress: String) {
        Task {
            do {
                let parameters = StytchB2BClient.Passwords.Discovery.ResetByEmailStartParameters(
                    emailAddress: emailAddress,
                    discoveryRedirectUrl: state.configuration.redirectUrl,
                    resetPasswordRedirectUrl: state.configuration.redirectUrl,
                    resetPasswordExpirationMinutes: state.configuration.sessionDurationMinutes,
                    resetPasswordTemplateId: state.configuration.passwordOptions?.resetPasswordTemplateId
                )
                _ = try await StytchB2BClient.passwords.discovery.resetByEmailStart(parameters: parameters)
                delegate?.didSendDiscoveryResetByEmailStart()
            } catch {
                delegate?.didError(error: error)
            }
        }
    }
}

struct PasswordForgotState {
    let configuration: StytchB2BUIClient.Configuration
}
