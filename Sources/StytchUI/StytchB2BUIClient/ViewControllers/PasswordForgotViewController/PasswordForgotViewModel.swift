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

    func resetPasswordByEmailIfPossible(emailAddress: String) {
        MemberManager.updateMemberEmailAddress(emailAddress)
        if state.configuration.computedAuthFlowType == .discovery {
            discoveryResetPasswordByEmailStart(emailAddress)
        } else {
            organizationResetPasswordByEmail(emailAddress)
        }
    }

    func organizationResetPasswordByEmail(_ emailAddress: String) {
        Task {
            do {
                let member = try await AuthenticationOperations.searchMember(emailAddress: emailAddress)
                if let memberPasswordId = member?.memberPasswordId, memberPasswordId.isEmpty == false {
                    try await AuthenticationOperations.organizationResetPasswordByEmailStart(configuration: state.configuration, emailAddress: emailAddress)
                    delegate?.didSendResetByEmailStart()
                } else {
                    try await AuthenticationOperations.sendEmailMagicLinkIfPossible(configuration: state.configuration, emailAddress: emailAddress)
                    delegate?.didSendEmailMagicLink()
                }
            } catch {
                delegate?.didError(error: error)
            }
        }
    }

    func discoveryResetPasswordByEmailStart(_ emailAddress: String) {
        Task {
            do {
                try await AuthenticationOperations.discoveryResetPasswordByEmailStart(configuration: state.configuration, emailAddress: emailAddress)
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
