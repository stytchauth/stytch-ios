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
        StytchUIClient.pendingResetEmail = nil
    }

    func testSessionDurationMinutesReadsFromConfig() {
        let state = PasswordState(
            config: .init(
                stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
                products: []
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        _ = PasswordViewModel(state: state)
        XCTAssert(state.config.stytchClientConfiguration.defaultSessionDuration == 5)
    }

    func testCreatesCorrectResetByEmailStartParams() {
        let passwordOptions: StytchUIClient.PasswordOptions = .init(
            loginExpiration: 123,
            resetPasswordExpiration: 456,
            resetPasswordTemplateId: "reset-password-template-id"
        )
        let config: StytchUIClient.Configuration = .init(
            stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
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
            loginRedirectUrl: config.redirectUrl,
            loginExpirationMinutes: passwordOptions.loginExpiration,
            resetPasswordRedirectUrl: config.redirectUrl,
            resetPasswordExpirationMinutes: passwordOptions.resetPasswordExpiration,
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
            stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
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
            loginExpirationMinutes: magicLinkOptions.loginExpiration,
            loginTemplateId: magicLinkOptions.loginTemplateId,
            signupMagicLinkUrl: config.redirectUrl,
            signupExpirationMinutes: magicLinkOptions.signupExpiration,
            signupTemplateId: magicLinkOptions.signupTemplateId
        )
        let result = viewModel.params(email: "test@stytch.com", magicLink: magicLinkOptions)
        XCTAssert(result == expected)
    }

    func testCheckStrengthCallsStrengthCheck() async throws {
        let state = PasswordState(
            config: .init(
                stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
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
                stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
                products: []
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let spy: PasswordsProtocol = PasswordsSpy(callback: calledMethodCallback)
        let viewModel = PasswordViewModel(state: state, passwordClient: spy)
        _ = try await viewModel.setPassword(token: "", password: "")
        XCTAssert(calledMethod == .passwordsResetByEmail)
    }

    func testSignupCallsCreateAndReportsToOnAuthCallback() async throws {
        let state = PasswordState(
            config: .init(
                stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
                products: []
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let spy: PasswordsProtocol = PasswordsSpy(callback: calledMethodCallback)
        let viewModel = PasswordViewModel(state: state, passwordClient: spy)
        _ = try await viewModel.signup(email: "", password: "")
        XCTAssert(calledMethod == .passwordsCreate)
    }

    func testLoginCallsAuthenticateAndReportsToOnAuthCallback() async throws {
        let state = PasswordState(
            config: .init(
                stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
                products: []
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let spy: PasswordsProtocol = PasswordsSpy(callback: calledMethodCallback)
        let viewModel = PasswordViewModel(state: state, passwordClient: spy)
        _ = try await viewModel.login(email: "", password: "")
        XCTAssert(calledMethod == .passwordsAuthenticate)
    }

    func testLoginWithEmailExitsEarlyWhenEMLProductIsNotConfigured() async throws {
        let state = PasswordState(
            config: .init(
                stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
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
                stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
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
                stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
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
                stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
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
