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

    init(state: AuthInputState) {
        self.state = state
    }
}

extension AuthInputViewModel: AuthInputViewModelProtocol {
    func sendMagicLink(email: String) async throws {
        if let magicLink = state.config.magicLink {
            let params = params(email: email, magicLink: magicLink)
            _ = try await StytchClient.magicLinks.email.loginOrCreate(parameters: params)
        }
    }
    
    func resetPassword(email: String) async throws {
        if let password = state.config.password {
            let params = params(email: email, password: password)
            _ = try await StytchClient.passwords.resetByEmailStart(parameters: params)
        }
    }
    
    func getUserIntent(email: String) async throws -> PasswordState.Intent? {
        let userSearch: UserSearchResponse = try await StytchClient._uiRouter.post(to: .userSearch, parameters: JSON.object(["email": .string(email)]))
        return userSearch.userType.passwordIntent
    }

    func continueWithPhone(phone: String, formattedPhone: String) async throws -> (StytchClient.OTP.OTPResponse, Date) {
        let expiry = Date().addingTimeInterval(120)
        let result = try await StytchClient.otps.loginOrCreate(parameters: .init(deliveryMethod: .sms(phoneNumber: phone), expiration: state.config.sms?.expiration))
        return (result, expiry)
    }
}

private extension AuthInputViewModel {
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

private struct UserSearchResponse: Decodable {
    enum UserType: String, Decodable {
        case new
        case password
        case passwordless
    }

    let userType: UserType
}

private extension UserSearchResponse.UserType {
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
