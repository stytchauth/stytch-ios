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
    let magicLinksClient: StytchClient.MagicLinks

    init(
        state: PasswordState,
        passwordClient: PasswordsProtocol = StytchClient.passwords,
        magicLinksClient: StytchClient.MagicLinks = StytchClient.magicLinks
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
        let response = try await passwordClient.resetByEmail(parameters: .init(token: token, password: password, sessionDuration: sessionDuration))
        StytchUIClient.onAuthCallback?(response)
    }

    func signup(email: String, password: String) async throws {
        let response = try await passwordClient.create(parameters: .init(email: email, password: password, sessionDuration: sessionDuration))
        StytchUIClient.onAuthCallback?(response)
    }

    func login(email: String, password: String) async throws {
        let response = try await passwordClient.authenticate(parameters: .init(email: email, password: password, sessionDuration: sessionDuration))
        StytchUIClient.onAuthCallback?(response)
    }

    func loginWithEmail(email: String) async throws {
        guard let magicLink = state.config.magicLink else { return }
        let params = params(email: email, magicLink: magicLink)
        _ = try await magicLinksClient.email.loginOrCreate(parameters: params)
    }

    func forgotPassword(email: String) async throws {
        guard let password = state.config.password else { return }
        StytchUIClient.pendingResetEmail = email
        let params = params(email: email, password: password)
        _ = try await passwordClient.resetByEmailStart(parameters: params)
    }
}

struct PasswordState {
    enum Intent {
        case signup
        case login
        case enterNewPassword(token: String)
    }

    let config: StytchUIClient.Configuration
    let intent: Intent
    let email: String
    let magicLinksEnabled: Bool
}

extension PasswordViewModel {
    var sessionDuration: Minutes {
        state.config.session?.sessionDuration ?? .defaultSessionDuration
    }

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
