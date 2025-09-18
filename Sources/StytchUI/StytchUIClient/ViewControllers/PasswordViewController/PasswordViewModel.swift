import Foundation
import StytchCore

protocol PasswordViewModelProtocol {
    func loginWithEmail(email: String) async throws
    func forgotPassword(email: String) async throws
    func setPassword(token: String, password: String) async throws
    func signup(email: String, password: String) async throws
    func login(email: String, password: String) async throws
    func checkStrength(email: String?, password: String) async throws -> StytchClient.Passwords.StrengthCheckResponse
}

final class PasswordViewModel {
    let state: PasswordState
    let passwordClient: PasswordsProtocol
    let magicLinksClient: MagicLinksEmailProtocol

    init(
        state: PasswordState,
        passwordClient: PasswordsProtocol = StytchClient.passwords,
        magicLinksClient: MagicLinksEmailProtocol = StytchClient.magicLinks.email
    ) {
        self.state = state
        self.passwordClient = passwordClient
        self.magicLinksClient = magicLinksClient
    }
}

extension PasswordViewModel: PasswordViewModelProtocol {
    func checkStrength(email: String?, password: String) async throws -> StytchClient.Passwords.StrengthCheckResponse {
        try await passwordClient.strengthCheck(parameters: .init(email: email, password: password))
    }

    func setPassword(token: String, password: String) async throws {
        _ = try await passwordClient.resetByEmail(parameters: .init(token: token, password: password))
    }

    func signup(email: String, password: String) async throws {
        _ = try await passwordClient.create(parameters: .init(email: email, password: password))
    }

    func login(email: String, password: String) async throws {
        _ = try await passwordClient.authenticate(parameters: .init(email: email, password: password))
    }

    func loginWithEmail(email: String) async throws {
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

struct PasswordState {
    enum Intent: Equatable {
        case signup
        case login
        case enterNewPassword(token: String)
    }

    let config: StytchUIClient.Configuration
    let intent: Intent
    let email: String?
    let magicLinksEnabled: Bool
}

extension PasswordViewModel {
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
