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
                products: .init(),
                session: .init(sessionDuration: 123)
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let viewModel = PasswordViewModel(state: state)
        XCTAssert(viewModel.sessionDuration.rawValue == 123)
    }

    func testSessionDurationMinutesReadsFromDefaultWhenNotConfigured() {
        let state = PasswordState(
            config: .init(
                products: .init()
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let viewModel = PasswordViewModel(state: state)
        XCTAssert(viewModel.sessionDuration == Minutes.defaultSessionDuration)
    }

    func testCreatesCorrectResetByEmailStartParams() {
        let passwordConfig: StytchUIClient.Configuration.Password = .init(
            loginURL: .init(string: "myapp://test-login"),
            loginExpiration: 123,
            resetPasswordURL: .init(string: "myapp://test-reset"),
            resetPasswordExpiration: 456,
            resetPasswordTemplateId: "reset-password-template-id"
        )
        let state = PasswordState(
            config: .init(
                products: .init()
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let viewModel = PasswordViewModel(state: state)
        let expected: StytchClient.Passwords.ResetByEmailStartParameters = .init(
            email: "test@stytch.com",
            loginUrl: passwordConfig.loginURL,
            loginExpiration: passwordConfig.loginExpiration,
            resetPasswordUrl: passwordConfig.resetPasswordURL,
            resetPasswordExpiration: passwordConfig.resetPasswordExpiration,
            resetPasswordTemplateId: passwordConfig.resetPasswordTemplateId
        )
        let result = viewModel.params(email: "test@stytch.com", password: passwordConfig)
        XCTAssert(result == expected)
    }

    func testCreatesCorrectMagicLinkParams() {
        let magicLinkConfig: StytchUIClient.Configuration.MagicLink = .init(
            loginMagicLinkUrl: .init(string: "myapp://test-login"),
            loginExpiration: 123,
            loginTemplateId: "login-template-id",
            signupMagicLinkUrl: .init(string: "myapp://test-signup"),
            signupExpiration: 456,
            signupTemplateId: "signup-template-id"
        )
        let state = PasswordState(
            config: .init(
                products: .init()
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let viewModel = PasswordViewModel(state: state)
        let expected: StytchClient.MagicLinks.Email.Parameters = .init(
            email: "test@stytch.com",
            loginMagicLinkUrl: magicLinkConfig.loginMagicLinkUrl,
            loginExpiration: magicLinkConfig.loginExpiration,
            loginTemplateId: magicLinkConfig.loginTemplateId,
            signupMagicLinkUrl: magicLinkConfig.signupMagicLinkUrl,
            signupExpiration: magicLinkConfig.signupExpiration,
            signupTemplateId: magicLinkConfig.signupTemplateId
        )
        let result = viewModel.params(email: "test@stytch.com", magicLink: magicLinkConfig)
        XCTAssert(result == expected)
    }

    func testCheckStrengthCallsStrengthCheck() async throws {
        let state = PasswordState(
            config: .init(
                products: .init()
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
                products: .init()
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
                products: .init()
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
                products: .init()
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
                products: .init()
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
                products: .init(
                    magicLink: .init()
                )
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
                products: .init()
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
                products: .init(
                    password: .init()
                )
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
