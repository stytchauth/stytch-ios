import Foundation
import StytchCore

protocol AuthInputViewModelProtocol {
    func getUserIntent(email: String) async throws -> PasswordState.Intent?
    func resetPassword(email: String) async throws
    func sendMagicLink(email: String) async throws
    func continueWithPhone(phone: String, formattedPhone: String) async throws -> (StytchClient.OTP.OTPResponse, Date)
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
        }
    }

    func resetPassword(email: String) async throws {
        if let password = state.config.password {
            let params = params(email: email, password: password)
            _ = try await passwordClient.resetByEmailStart(parameters: params)
        }
    }

    func getUserIntent(email: String) async throws -> PasswordState.Intent? {
        let userSearch: UserSearchResponse = try await StytchClient._uiRouter.post(to: .userSearch, parameters: JSON.object(["email": .string(email)]))
        return userSearch.userType.passwordIntent
    }

    func continueWithPhone(phone: String, formattedPhone _: String) async throws -> (StytchClient.OTP.OTPResponse, Date) {
        let expiry = Date().addingTimeInterval(120)
        let result = try await otpClient.loginOrCreate(parameters: .init(deliveryMethod: .sms(phoneNumber: phone), expiration: state.config.sms?.expiration))
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
