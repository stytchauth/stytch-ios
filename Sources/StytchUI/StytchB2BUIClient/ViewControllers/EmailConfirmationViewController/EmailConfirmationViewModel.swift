import StytchCore

final class EmailConfirmationViewModel {
    let state: EmailConfirmationState

    init(
        state: EmailConfirmationState
    ) {
        self.state = state
    }

    func resetByEmailStart(emailAddress: String) async throws {
        guard let organizationId = OrganizationManager.organizationId else {
            throw StytchSDKError.noOrganziationId
        }

        let parameters = StytchB2BClient.Passwords.ResetByEmailStartParameters(
            organizationId: Organization.ID(rawValue: organizationId),
            emailAddress: emailAddress,
            loginUrl: state.configuration.redirectUrl,
            resetPasswordUrl: state.configuration.redirectUrl,
            resetPasswordExpiration: state.configuration.passwordOptions?.resetPasswordExpirationMinutes,
            resetPasswordTemplateId: state.configuration.passwordOptions?.resetPasswordTemplateId
        )
        _ = try await StytchB2BClient.passwords.resetByEmailStart(parameters: parameters)
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
