import Foundation
import StytchCore
@preconcurrency import SwiftyJSON

protocol AuthInputViewModelProtocol {
    func getUserIntent(email: String) async throws -> PasswordState.Intent?
    func resetPassword(email: String) async throws
    func sendMagicLink(email: String) async throws
    func continueWithEmail(email: String) async throws -> (StytchClient.OTP.OTPResponse, Date)
    func continueWithPhone(phone: String, formattedPhone: String) async throws -> (StytchClient.OTP.OTPResponse, Date)
    func continueWithWhatsApp(phone: String, formattedPhone: String) async throws -> (StytchClient.OTP.OTPResponse, Date)
}

final class AuthInputViewModel {
    let state: AuthInputState
    let passwordClient: PasswordsProtocol
    let magicLinksClient: MagicLinksEmailProtocol
    let otpClient: OTPProtocol

    init(
        state: AuthInputState,
        passwordClient: PasswordsProtocol = StytchClient.passwords,
        magicLinksClient: MagicLinksEmailProtocol = StytchClient.magicLinks.email,
        otpClient: OTPProtocol = StytchClient.otps
    ) {
        self.state = state
        self.passwordClient = passwordClient
        self.magicLinksClient = magicLinksClient
        self.otpClient = otpClient
    }
}

extension AuthInputViewModel: AuthInputViewModelProtocol {
    func sendMagicLink(email: String) async throws {
        guard state.config.supportsEmailMagicLinks else { return }
        let magicLink = state.config.magicLinkOptions
        let params = params(email: email, magicLink: magicLink)
        _ = try await magicLinksClient.loginOrCreate(parameters: params)
        try? await EventsClient.logEvent(parameters: .init(eventName: "email_sent", details: ["email": email, "type": "login_or_create_eml"]))
    }

    func resetPassword(email: String) async throws {
        guard state.config.supportsPasswords else { return }
        let password = state.config.passwordOptions
        let params = params(email: email, password: password)
        _ = try await passwordClient.resetByEmailStart(parameters: params)
        try? await EventsClient.logEvent(parameters: .init(eventName: "email_sent", details: ["email": email, "type": "reset_password"]))
    }

    func getUserIntent(email: String) async throws -> PasswordState.Intent? {
        let userSearch: StytchClient.UserManagement.UserSearchResponse = try await StytchClient.user.searchUser(email: email)
        return userSearch.userType.passwordIntent
    }

    func continueWithEmail(email: String) async throws -> (StytchClient.OTP.OTPResponse, Date) {
        let expiry = Date().addingTimeInterval(120)
        let result = try await otpClient.loginOrCreate(parameters: .init(deliveryMethod: .email(email: email, loginTemplateId: state.config.otpOptions?.loginTemplateId, signupTemplateId: state.config.otpOptions?.signupTemplateId), expirationMinutes: state.config.otpOptions?.expiration))
        return (result, expiry)
    }

    func continueWithPhone(phone: String, formattedPhone _: String) async throws -> (StytchClient.OTP.OTPResponse, Date) {
        let expiry = Date().addingTimeInterval(120)
        let result = try await otpClient.loginOrCreate(parameters: .init(deliveryMethod: .sms(phoneNumber: phone), expirationMinutes: state.config.otpOptions?.expiration))
        return (result, expiry)
    }

    func continueWithWhatsApp(phone: String, formattedPhone _: String) async throws -> (StytchClient.OTP.OTPResponse, Date) {
        let expiry = Date().addingTimeInterval(120)
        let result = try await otpClient.loginOrCreate(parameters: .init(deliveryMethod: .whatsapp(phoneNumber: phone), expirationMinutes: state.config.otpOptions?.expiration))
        return (result, expiry)
    }
}

extension AuthInputViewModel {
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

struct AuthInputState {
    let config: StytchUIClient.Configuration
}

internal extension StytchClient.UserManagement.UserType {
    var passwordIntent: PasswordState.Intent? {
        switch self {
        case .new:
            return .signup
        case .password:
            return .login
        case .passwordless:
            return nil
        }
    }
}
