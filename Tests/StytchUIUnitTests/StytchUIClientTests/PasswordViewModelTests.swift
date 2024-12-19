import XCTest
@testable import StytchCore
@testable import StytchUI

final class PasswordViewModelTests: BaseTestCase {
    var calledMethod: CalledMethod?

    func calledMethodCallback(method: CalledMethod) {
        calledMethod = method
    }

    override func setUp() async throws {
        try await super.setUp()
        calledMethod = nil
        StytchUIClient.onAuthCallback = nil
        StytchUIClient.pendingResetEmail = nil
    }

    func testSessionDurationMinutesReadsFromConfig() {
        let state = PasswordState(
            config: .init(
                publicToken: "publicToken",
                products: [],
                sessionDurationMinutes: 123
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let viewModel = PasswordViewModel(state: state)
        XCTAssert(state.config.sessionDurationMinutes == 123)
    }

    func testSessionDurationMinutesReadsFromDefaultWhenNotConfigured() {
        let state = PasswordState(
            config: .init(
                publicToken: "publicToken",
                products: []
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let viewModel = PasswordViewModel(state: state)
        XCTAssert(state.config.sessionDurationMinutes == Minutes.defaultSessionDuration)
    }

    func testCreatesCorrectResetByEmailStartParams() {
        let passwordOptions: StytchUIClient.PasswordOptions = .init(
            loginExpiration: 123,
            resetPasswordExpiration: 456,
            resetPasswordTemplateId: "reset-password-template-id"
        )
        let config: StytchUIClient.Configuration = .init(
            publicToken: "publicToken",
            products: [],
            passwordOptions: passwordOptions
        )
        let state = PasswordState(
            config: config,
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let viewModel = PasswordViewModel(state: state)
        let expected: StytchClient.Passwords.ResetByEmailStartParameters = .init(
            email: "test@stytch.com",
            loginUrl: config.redirectUrl,
            loginExpiration: passwordOptions.loginExpiration,
            resetPasswordUrl: config.redirectUrl,
            resetPasswordExpiration: passwordOptions.resetPasswordExpiration,
            resetPasswordTemplateId: passwordOptions.resetPasswordTemplateId
        )
        let result = viewModel.params(email: "test@stytch.com", password: passwordOptions)
        XCTAssert(result == expected)
    }

    func testCreatesCorrectMagicLinkParams() {
        let magicLinkOptions: StytchUIClient.MagicLinkOptions = .init(
            loginExpiration: 123,
            loginTemplateId: "login-template-id",
            signupExpiration: 456,
            signupTemplateId: "signup-template-id"
        )
        let config: StytchUIClient.Configuration = .init(
            publicToken: "publicToken",
            products: [],
            magicLinkOptions: magicLinkOptions
        )
        let state = PasswordState(
            config: config,
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let viewModel = PasswordViewModel(state: state)
        let expected: StytchClient.MagicLinks.Email.Parameters = .init(
            email: "test@stytch.com",
            loginMagicLinkUrl: config.redirectUrl,
            loginExpiration: magicLinkOptions.loginExpiration,
            loginTemplateId: magicLinkOptions.loginTemplateId,
            signupMagicLinkUrl: config.redirectUrl,
            signupExpiration: magicLinkOptions.signupExpiration,
            signupTemplateId: magicLinkOptions.signupTemplateId
        )
        let result = viewModel.params(email: "test@stytch.com", magicLink: magicLinkOptions)
        XCTAssert(result == expected)
    }

    func testCheckStrengthCallsStrengthCheck() async throws {
        let state = PasswordState(
            config: .init(
                publicToken: "publicToken",
                products: []
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let spy: PasswordsProtocol = PasswordsSpy(callback: calledMethodCallback)
        let viewModel = PasswordViewModel(state: state, passwordClient: spy)
        _ = try await viewModel.checkStrength(email: "test@stytch.com", password: "password")
        XCTAssert(calledMethod == .passwordsStrengthCheck)
    }

    func testSetPasswordCallsResetByEmailAndReportsToOnAuthCallback() async throws {
        let state = PasswordState(
            config: .init(
                publicToken: "publicToken",
                products: []
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let spy: PasswordsProtocol = PasswordsSpy(callback: calledMethodCallback)
        let viewModel = PasswordViewModel(state: state, passwordClient: spy)
        var didCallUICallback = false
        StytchUIClient.onAuthCallback = { _ in
            didCallUICallback = true
        }
        _ = try await viewModel.setPassword(token: "", password: "")
        XCTAssert(calledMethod == .passwordsResetByEmail)
        XCTAssert(didCallUICallback)
    }

    func testSignupCallsCreateAndReportsToOnAuthCallback() async throws {
        let state = PasswordState(
            config: .init(
                publicToken: "publicToken",
                products: []
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let spy: PasswordsProtocol = PasswordsSpy(callback: calledMethodCallback)
        let viewModel = PasswordViewModel(state: state, passwordClient: spy)
        var didCallUICallback = false
        StytchUIClient.onAuthCallback = { _ in
            didCallUICallback = true
        }
        _ = try await viewModel.signup(email: "", password: "")
        XCTAssert(calledMethod == .passwordsCreate)
        XCTAssert(didCallUICallback)
    }

    func testLoginCallsAuthenticateAndReportsToOnAuthCallback() async throws {
        let state = PasswordState(
            config: .init(
                publicToken: "publicToken",
                products: []
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let spy: PasswordsProtocol = PasswordsSpy(callback: calledMethodCallback)
        let viewModel = PasswordViewModel(state: state, passwordClient: spy)
        var didCallUICallback = false
        StytchUIClient.onAuthCallback = { _ in
            didCallUICallback = true
        }
        _ = try await viewModel.login(email: "", password: "")
        XCTAssert(calledMethod == .passwordsAuthenticate)
        XCTAssert(didCallUICallback)
    }

    func testLoginWithEmailExitsEarlyWhenEMLProductIsNotConfigured() async throws {
        let state = PasswordState(
            config: .init(
                publicToken: "publicToken",
                products: []
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let spy: MagicLinksEmailProtocol = MagicLinksSpy(callback: calledMethodCallback)
        let viewModel = PasswordViewModel(state: state, magicLinksClient: spy)
        _ = try await viewModel.loginWithEmail(email: "")
        XCTAssert(calledMethod == nil)
    }

    func testLoginWithEmailCallsLoginOrCreateWhenEMLProductIsConfigured() async throws {
        let state = PasswordState(
            config: .init(
                publicToken: "publicToken",
                products: [.emailMagicLinks]
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let spy: MagicLinksEmailProtocol = MagicLinksSpy(callback: calledMethodCallback)
        let viewModel = PasswordViewModel(state: state, magicLinksClient: spy)
        _ = try await viewModel.loginWithEmail(email: "")
        XCTAssert(calledMethod == .magicLinksLoginOrCreate)
    }

    func testForgotPasswordExitsEarlyWhenPasswordProductIsNotConfigured() async throws {
        let state = PasswordState(
            config: .init(
                publicToken: "publicToken",
                products: []
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let spy: PasswordsProtocol = PasswordsSpy(callback: calledMethodCallback)
        let viewModel = PasswordViewModel(state: state, passwordClient: spy)
        _ = try await viewModel.forgotPassword(email: "test@stytch.com")
        XCTAssert(calledMethod == nil)
        XCTAssert(StytchUIClient.pendingResetEmail == nil)
    }

    func testForgotPasswordCallsResetByEmailStartAndSetsPendingResetEmailWhenPasswordProductIsConfigured() async throws {
        let state = PasswordState(
            config: .init(
                publicToken: "publicToken",
                products: [.passwords]
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let spy: PasswordsProtocol = PasswordsSpy(callback: calledMethodCallback)
        let viewModel = PasswordViewModel(state: state, passwordClient: spy)
        _ = try await viewModel.forgotPassword(email: "test@stytch.com")
        XCTAssert(calledMethod == .passwordsResetByEmailStart)
        XCTAssert(StytchUIClient.pendingResetEmail == "test@stytch.com")
    }
}
