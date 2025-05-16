import Foundation
import StytchCore

protocol EmailConfirmationViewModelProtocol {
    func forgotPassword(email: String) async throws
    func loginWithoutPassword(email: String) async throws
}

final class EmailConfirmationViewModel {
    let state: EmailConfirmationState
    let passwordClient: PasswordsProtocol
    let magicLinksClient: MagicLinksEmailProtocol

    init(
        state: EmailConfirmationState,
        passwordClient: PasswordsProtocol = StytchClient.passwords,
        magicLinksClient: MagicLinksEmailProtocol = StytchClient.magicLinks.email
    ) {
        self.state = state
        self.passwordClient = passwordClient
        self.magicLinksClient = magicLinksClient
    }
}

extension EmailConfirmationViewModel: EmailConfirmationViewModelProtocol {
    func loginWithoutPassword(email: String) async throws {
        guard state.config.supportsEmailMagicLinks else { return }
        let magicLink = state.config.magicLinkOptions
        let params = params(email: email, magicLink: magicLink)
        _ = try await magicLinksClient.loginOrCreate(parameters: params)
        try? await EventsClient.logEvent(parameters: .init(eventName: "email_sent", details: ["email": email, "type": "login_or_create_eml"]))
    }

    func forgotPassword(email: String) async throws {
        guard state.config.supportsPasswords else { return }
        let password = state.config.passwordOptions
        StytchUIClient.pendingResetEmail = email
        let params = params(email: email, password: password)
        _ = try await passwordClient.resetByEmailStart(parameters: params)
        try? await EventsClient.logEvent(parameters: .init(eventName: "email_sent", details: ["email": email, "type": "reset_password"]))
    }
}

struct EmailConfirmationState {
    let config: StytchUIClient.Configuration
    let email: String
    let title: String
    let infoComponents: [AttrStringComponent]
    let actionComponents: [AttrStringComponent]
    let secondaryAction: (title: String, action: EmailConfirmationAction)?
    let retryAction: RetryAction
}

extension EmailConfirmationState {
    typealias RetryAction = () async throws -> Void
    static func forgotPassword(config: StytchUIClient.Configuration, email: String, retryAction: @escaping RetryAction) -> Self {
        .init(
            config: config,
            email: email,
            title: LocalizationManager.stytch_b2c_password_forgot,
            infoComponents: [
                .string(LocalizationManager.stytch_b2c_email_confirmation_link_to_reset_password_sent),
                .bold(.string(email)),
            ],
            actionComponents: [
                .bold(.string(LocalizationManager.stytch_b2c_email_confirmation_didnt_get_it_resend_email)),
            ],
            secondaryAction: nil,
            retryAction: retryAction
        )
    }

    static func checkYourEmail(config: StytchUIClient.Configuration, email: String, retryAction: @escaping RetryAction) -> Self {
        .init(
            config: config,
            email: email,
            title: .checkEmail,
            infoComponents: [
                .string(.loginLinkSentToYou),
                .bold(.string(email)),
            ],
            actionComponents: [
                .bold(.string(LocalizationManager.stytch_b2c_email_confirmation_didnt_get_it_resend_email)),
            ],
            secondaryAction: nil,
            retryAction: retryAction
        )
    }

    static func checkYourEmailCreatePasswordInstead(config: StytchUIClient.Configuration, email: String, retryAction: @escaping RetryAction) -> Self {
        .init(
            config: config,
            email: email,
            title: .checkEmail,
            infoComponents: [
                .string(.loginLinkSentToYou),
                .bold(.string(email)),
            ],
            actionComponents: [
                .bold(.string(LocalizationManager.stytch_b2c_email_confirmation_didnt_get_it_resend_email)),
            ],
            secondaryAction: (LocalizationManager.stytch_b2c_create_password_instead, .didTapCreatePassword(email: email)),
            retryAction: retryAction
        )
    }

    static func checkYourEmailResetPassword(config: StytchUIClient.Configuration, email: String, retryAction: @escaping RetryAction) -> Self {
        .init(
            config: config,
            email: email,
            title: .checkEmailForNewPassword,
            infoComponents: [
                .string(.loginLinkSentToYou),
                .bold(.string(email)),
                .string(LocalizationManager.stytch_b2c_email_confirmation_to_create_password),
            ],
            actionComponents: [
                .bold(.string(LocalizationManager.stytch_b2c_email_confirmation_didnt_get_it_resend_email)),
            ],
            secondaryAction: nil,
            retryAction: retryAction
        )
    }

    static func checkYourEmailResetReturning(config: StytchUIClient.Configuration, email: String, retryAction: @escaping RetryAction) -> Self {
        .init(
            config: config,
            email: email,
            title: .checkEmailForNewPassword,
            infoComponents: [
                .string(LocalizationManager.stytch_b2c_email_confirmation_make_sure_acount_secure),
                .bold(.string(email)),
            ],
            actionComponents: [
                .bold(.string(LocalizationManager.stytch_b2c_email_confirmation_didnt_get_it_resend_email)),
            ],
            secondaryAction: (.loginWithoutPassword, .didTapLoginWithoutPassword(email: email)),
            retryAction: retryAction
        )
    }

    static func checkYourEmailResetBreached(config: StytchUIClient.Configuration, email: String, retryAction: @escaping RetryAction) -> Self {
        .init(
            config: config,
            email: email,
            title: .checkEmailForNewPassword,
            infoComponents: [
                .string(LocalizationManager.stytch_b2c_email_confirmation_password_breach),
                .bold(.string(email)),
                .string(LocalizationManager.stytch_b2c_email_confirmation_to_reset_password),
            ],
            actionComponents: [
                .bold(.string(LocalizationManager.stytch_b2c_email_confirmation_didnt_get_it_resend_email)),
            ],
            secondaryAction: (.loginWithoutPassword, .didTapLoginWithoutPassword(email: email)),
            retryAction: retryAction
        )
    }
}

enum EmailConfirmationAction: Equatable {
    case didTapCreatePassword(email: String)
    case didTapLoginWithoutPassword(email: String)
}

internal extension EmailConfirmationViewModel {
    func params(email: String, password: StytchUIClient.PasswordOptions?) -> StytchClient.Passwords.ResetByEmailStartParameters {
        .init(
            email: email,
            loginRedirectUrl: state.config.redirectUrl,
            loginExpirationMinutes: password?.loginExpiration,
            resetPasswordRedirectUrl: state.config.redirectUrl,
            resetPasswordExpirationMinutes: password?.resetPasswordExpiration,
            resetPasswordTemplateId: password?.resetPasswordTemplateId,
            locale: state.config.locale
        )
    }

    func params(email: String, magicLink: StytchUIClient.MagicLinkOptions?) -> StytchClient.MagicLinks.Email.Parameters {
        .init(
            email: email,
            loginMagicLinkUrl: state.config.redirectUrl,
            loginExpirationMinutes: magicLink?.loginExpiration,
            loginTemplateId: magicLink?.loginTemplateId,
            signupMagicLinkUrl: state.config.redirectUrl,
            signupExpirationMinutes: magicLink?.signupExpiration,
            signupTemplateId: magicLink?.signupTemplateId,
            locale: state.config.locale
        )
    }
}

internal extension String {
    static let checkEmail: String = LocalizationManager.stytch_b2c_email_confirmation_check_email
    static let checkEmailForNewPassword: String = LocalizationManager.stytch_b2c_email_confirmation_check_email_for_password
    static let loginLinkSentToYou: String = LocalizationManager.stytch_b2c_email_confirmation_login_link_sent
    static let loginWithoutPassword: String = LocalizationManager.stytch_b2c_email_confirmation_login_without_password
}
