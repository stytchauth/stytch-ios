import StytchCore

final class B2BEmailConfirmationViewModel {
    let state: B2BEmailConfirmationState

    init(
        state: B2BEmailConfirmationState
    ) {
        self.state = state
    }

    func resendResetPasswordByEmailIfPossible(emailAddress: String) async throws {
        MemberManager.updateMemberEmailAddress(emailAddress)
        if state.configuration.computedAuthFlowType == .discovery {
            try await AuthenticationOperations.discoveryResetPasswordByEmailStart(configuration: state.configuration, emailAddress: emailAddress)
        } else {
            let member = try await AuthenticationOperations.searchMember(emailAddress: emailAddress)
            if member != nil {
                try await AuthenticationOperations.organizationResetPasswordByEmailStart(configuration: state.configuration, emailAddress: emailAddress)
            } else {
                try await AuthenticationOperations.sendEmailMagicLinkIfPossible(configuration: state.configuration, emailAddress: emailAddress)
            }
        }
    }
}

extension B2BEmailConfirmationViewModel {
    var title: String {
        switch state.type {
        case .emailConfirmation:
            return LocalizationManager.stytch_b2b_email_confirmation_check_email
        case .passwordSetNew:
            return LocalizationManager.stytch_b2b_email_confirmation_check_email
        case .passwordResetVerify:
            return LocalizationManager.stytch_b2b_email_confirmation_verify_email
        }
    }

    var message: String {
        switch state.type {
        case .emailConfirmation:
            return LocalizationManager.stytch_b2b_email_confirmation_email_sent
        case .passwordSetNew:
            return LocalizationManager.stytch_b2b_email_confirmation_login_link_sent
        case .passwordResetVerify:
            return LocalizationManager.stytch_b2b_email_confirmation_login_link_sent
        }
    }

    var primarySubtext: String {
        switch state.type {
        case .emailConfirmation:
            return LocalizationManager.stytch_b2b_email_confirmation_didnt_get_it
        case .passwordSetNew:
            return LocalizationManager.stytch_b2b_email_confirmation_didnt_get_it
        case .passwordResetVerify:
            return LocalizationManager.stytch_b2b_email_confirmation_didnt_get_it
        }
    }

    var secondaryBoldSubtext: String {
        switch state.type {
        case .emailConfirmation:
            return LocalizationManager.stytch_b2b_email_confirmation_try_again
        case .passwordSetNew:
            return LocalizationManager.stytch_b2b_email_confirmation_resend_email
        case .passwordResetVerify:
            return LocalizationManager.stytch_b2b_email_confirmation_resend_email
        }
    }
}

struct B2BEmailConfirmationState {
    let configuration: StytchB2BUIClient.Configuration
    let type: EmailConfirmationType
}

enum EmailConfirmationType {
    case emailConfirmation
    case passwordSetNew
    case passwordResetVerify
}
