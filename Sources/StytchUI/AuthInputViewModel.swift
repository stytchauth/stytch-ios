import Foundation
import StytchCore

protocol AuthInputViewModelDelegate {
    func launchCheckYourEmailResetReturning(email: String)
    func launchPassword(intent: PasswordState.Intent, email: String, magicLinksEnabled: Bool)
    func launchCheckYourEmail(email: String)
    func launchOTP(phone: String, formattedPhone: String, result: StytchClient.OTP.OTPResponse, expiry: Date)
}

protocol AuthInputViewModelProtocol {
    func continueWithEmail(email: String) async throws
    func continueWithPhone(phone: String, formattedPhone: String) async throws
}

final class AuthInputViewModel {
    let state: AuthInputState
    var delegate: AuthInputViewModelDelegate?

    init(state: AuthInputState) {
        self.state = state
    }

    func setDelegate(delegate: AuthInputViewModelDelegate) {
        self.delegate = delegate
    }
}

extension AuthInputViewModel: AuthInputViewModelProtocol {
    func continueWithEmail(email: String) async throws {
        if state.config.magicLink != nil, let password = state.config.password {
            let userSearch: UserSearchResponse = try await StytchClient._uiRouter.post(to: .userSearch, parameters: JSON.object(["email": .string(email)]))
            guard let intent = userSearch.userType.passwordIntent else {
                let params = params(email: email, password: password)
                _ = try await StytchClient.passwords.resetByEmailStart(parameters: params)
                DispatchQueue.main.async {
                    self.delegate?.launchCheckYourEmailResetReturning(email: email)
                }
                return
            }
            DispatchQueue.main.async {
                self.delegate?.launchPassword(intent: intent, email: email, magicLinksEnabled: self.state.config.magicLink != nil)
            }
        } else if let magicLink = state.config.magicLink {
            let parameters = params(email: email, magicLink: magicLink)
            _ = try await StytchClient.magicLinks.email.loginOrCreate(parameters: parameters)
            DispatchQueue.main.async {
                self.delegate?.launchCheckYourEmail(email: email)
            }
        }
    }

    func continueWithPhone(phone: String, formattedPhone: String) async throws {
        let expiry = Date().addingTimeInterval(120)
        let result = try await StytchClient.otps.loginOrCreate(parameters: .init(deliveryMethod: .sms(phoneNumber: phone), expiration: state.config.sms?.expiration))
        DispatchQueue.main.async {
            self.delegate?.launchOTP(phone: phone, formattedPhone: formattedPhone, result: result, expiry: expiry)
        }
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
