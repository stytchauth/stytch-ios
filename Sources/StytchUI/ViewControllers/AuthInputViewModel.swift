import Foundation
import StytchCore

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
        if let magicLink = state.config.magicLink {
            let params = params(email: email, magicLink: magicLink)
            _ = try await magicLinksClient.loginOrCreate(parameters: params)
            try? await StytchClient.events.logEvent(parameters: .init(eventName: "email_sent", details: ["email": email, "type": "login_or_create_eml"]))
        }
    }

    func resetPassword(email: String) async throws {
        if let password = state.config.password {
            let params = params(email: email, password: password)
            _ = try await passwordClient.resetByEmailStart(parameters: params)
            try? await StytchClient.events.logEvent(parameters: .init(eventName: "email_sent", details: ["email": email, "type": "reset_password"]))
        }
    }

    func getUserIntent(email: String) async throws -> PasswordState.Intent? {
        let userSearch: UserSearchResponse = try await StytchClient._uiRouter.post(to: .userSearch, parameters: JSON.object(["email": .string(email)]))
        return userSearch.userType.passwordIntent
    }

    func continueWithEmail(email: String) async throws -> (StytchClient.OTP.OTPResponse, Date) {
        let expiry = Date().addingTimeInterval(120)
        let result = try await otpClient.loginOrCreate(parameters: .init(deliveryMethod: .email(email: email, loginTemplateId: state.config.otp?.loginTemplateId, signupTemplateId: state.config.otp?.signupTemplateId), expiration: state.config.otp?.expiration))
        return (result, expiry)
    }

    func continueWithPhone(phone: String, formattedPhone _: String) async throws -> (StytchClient.OTP.OTPResponse, Date) {
        let expiry = Date().addingTimeInterval(120)
        let result = try await otpClient.loginOrCreate(parameters: .init(deliveryMethod: .sms(phoneNumber: phone), expiration: state.config.otp?.expiration))
        return (result, expiry)
    }

    func continueWithWhatsApp(phone: String, formattedPhone _: String) async throws -> (StytchClient.OTP.OTPResponse, Date) {
        let expiry = Date().addingTimeInterval(120)
        let result = try await otpClient.loginOrCreate(parameters: .init(deliveryMethod: .whatsapp(phoneNumber: phone), expiration: state.config.otp?.expiration))
        return (result, expiry)
    }
}

extension AuthInputViewModel {
    func params(email: String, password: StytchUIClient.Configuration.Password) -> StytchClient.Passwords.ResetByEmailStartParameters {
        .init(
            email: email,
            loginUrl: password.loginURL,
            loginExpiration: password.loginExpiration,
            resetPasswordUrl: password.resetPasswordURL,
            resetPasswordExpiration: password.resetPasswordExpiration,
            resetPasswordTemplateId: password.resetPasswordTemplateId
        )
    }

    func params(email: String, magicLink: StytchUIClient.Configuration.MagicLink) -> StytchClient.MagicLinks.Email.Parameters {
        .init(
            email: email,
            loginMagicLinkUrl: magicLink.loginMagicLinkUrl,
            loginExpiration: magicLink.loginExpiration,
            loginTemplateId: magicLink.loginTemplateId,
            signupMagicLinkUrl: magicLink.signupMagicLinkUrl,
            signupExpiration: magicLink.signupExpiration,
            signupTemplateId: magicLink.signupTemplateId
        )
    }
}

struct AuthInputState {
    let config: StytchUIClient.Configuration
}

internal struct UserSearchResponse: Decodable {
    enum UserType: String, Decodable {
        case new
        case password
        case passwordless
    }

    let userType: UserType
}

internal extension UserSearchResponse.UserType {
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
