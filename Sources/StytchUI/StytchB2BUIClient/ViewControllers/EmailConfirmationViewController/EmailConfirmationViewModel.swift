import StytchCore

final class EmailConfirmationViewModel {
    let state: EmailConfirmationState

    init(
        state: EmailConfirmationState
    ) {
        self.state = state
    }

    func resendResetPasswordByEmailIfPossible(emailAddress: String) async throws {
        MemberManager.updateMemberEmailAddress(emailAddress)
        if state.configuration.computedAuthFlowType == .discovery {
            try await AuthenticationOperations.discoveryResetPasswordByEmailStart(configuration: state.configuration, emailAddress: emailAddress)
        } else {
            if let member = try await AuthenticationOperations.searchMember(emailAddress: emailAddress) {
                try await AuthenticationOperations.organizationResetPasswordByEmailStart(configuration: state.configuration, emailAddress: emailAddress)
            } else {
                try await AuthenticationOperations.sendEmailMagicLinkIfPossible(configuration: state.configuration, emailAddress: emailAddress)
            }
        }
    }
}

extension EmailConfirmationViewModel {
    var title: String {
        switch state.type {
        case .emailConfirmation:
            return "Check your email"
        case .passwordSetNew:
            return "Check your email!"
        case .passwordResetVerify:
            return "Please verify your email"
        }
    }

    var message: String {
        switch state.type {
        case .emailConfirmation:
            return "An email was sent to"
        case .passwordSetNew:
            return "A login link was sent to you at"
        case .passwordResetVerify:
            return "A login link was sent to you at"
        }
    }

    var primarySubtext: String {
        switch state.type {
        case .emailConfirmation:
            return "Didn’t get it?"
        case .passwordSetNew:
            return "Didn't get it?"
        case .passwordResetVerify:
            return "Didn't get it?"
        }
    }

    var secondaryBoldSubtext: String {
        switch state.type {
        case .emailConfirmation:
            return "Try Again"
        case .passwordSetNew:
            return "Resend email"
        case .passwordResetVerify:
            return "Resend email"
        }
    }
}

struct EmailConfirmationState {
    let configuration: StytchB2BUIClient.Configuration
    let type: EmailConfirmationType
}

enum EmailConfirmationType {
    case emailConfirmation
    case passwordSetNew
    case passwordResetVerify
}
