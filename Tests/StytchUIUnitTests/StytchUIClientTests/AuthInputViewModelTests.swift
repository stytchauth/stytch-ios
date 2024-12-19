import XCTest
@testable import StytchCore
@testable import StytchUI

final class AuthInputViewModelTests: BaseTestCase {
    var calledMethod: CalledMethod?

    let magicLinkConfig: StytchUIClient.MagicLinkOptions = .init(
        loginExpiration: 123,
        loginTemplateId: "login-template-id",
        signupExpiration: 456,
        signupTemplateId: "signup-template-id"
    )

    let passwordConfig: StytchUIClient.PasswordOptions = .init(
        loginExpiration: 123,
        resetPasswordExpiration: 456,
        resetPasswordTemplateId: "reset-password-template-id"
    )

    func calledMethodCallback(method: CalledMethod) {
        calledMethod = method
    }

    override func setUp() async throws {
        try await super.setUp()
        calledMethod = nil
        StytchUIClient.onAuthCallback = nil
    }

    func testCreatesCorrectResetByEmailStartParams() {
        let config: StytchUIClient.Configuration = .init(
            publicToken: "publicToken",
            products: [.passwords],
            passwordOptions: passwordConfig
        )
        let state = AuthInputState(
            config: config
        )
        let viewModel = AuthInputViewModel(state: state)
        let expected: StytchClient.Passwords.ResetByEmailStartParameters = .init(
            email: "test@stytch.com",
            loginUrl: config.redirectUrl,
            loginExpiration: passwordConfig.loginExpiration,
            resetPasswordUrl: config.redirectUrl,
            resetPasswordExpiration: passwordConfig.resetPasswordExpiration,
            resetPasswordTemplateId: passwordConfig.resetPasswordTemplateId
        )
        let result = viewModel.params(email: "test@stytch.com", password: passwordConfig)
        XCTAssert(result == expected)
    }

    func testCreatesCorrectMagicLinkParams() {
        let config: StytchUIClient.Configuration = .init(
            publicToken: "publicToken",
            products: [.passwords],
            passwordOptions: passwordConfig
        )
        let state = AuthInputState(
            config: config
        )
        let viewModel = AuthInputViewModel(state: state)
        let expected: StytchClient.MagicLinks.Email.Parameters = .init(
            email: "test@stytch.com",
            loginMagicLinkUrl: config.redirectUrl,
            loginExpiration: magicLinkConfig.loginExpiration,
            loginTemplateId: magicLinkConfig.loginTemplateId,
            signupMagicLinkUrl: config.redirectUrl,
            signupExpiration: magicLinkConfig.signupExpiration,
            signupTemplateId: magicLinkConfig.signupTemplateId
        )
        let result = viewModel.params(email: "test@stytch.com", magicLink: magicLinkConfig)
        XCTAssert(result == expected)
    }

    func testSendMagicLinkDoesNothingIfMagicLinksAreNotConfigured() async throws {
        let state = AuthInputState(
            config: .init(
                publicToken: "publicToken",
                products: []
            )
        )
        let magicLinksSpy = MagicLinksSpy(callback: calledMethodCallback)
        let viewModel = AuthInputViewModel(
            state: state,
            magicLinksClient: magicLinksSpy
        )
        try await viewModel.sendMagicLink(email: "test@stytch.com")
        XCTAssert(calledMethod == nil)
    }

    func testSendMagicLinkCallsMagicLinksLoginOrCreateIfMagicLinksAreConfigured() async throws {
        let state = AuthInputState(
            config: .init(
                publicToken: "publicToken",
                products: [.emailMagicLinks],
                magicLinkOptions: magicLinkConfig
            )
        )
        let viewModel = AuthInputViewModel(
            state: state,
            magicLinksClient: MagicLinksSpy(callback: calledMethodCallback)
        )
        try await viewModel.sendMagicLink(email: "test@stytch.com")
        XCTAssert(calledMethod == .magicLinksLoginOrCreate)
    }

    func testResetPasswordDoesNothingIfPasswordsAreNotConfigured() async throws {
        let state = AuthInputState(
            config: .init(
                publicToken: "publicToken",
                products: []
            )
        )
        let viewModel = AuthInputViewModel(
            state: state,
            passwordClient: PasswordsSpy(callback: calledMethodCallback)
        )
        try await viewModel.resetPassword(email: "test@stytch.com")
        XCTAssert(calledMethod == nil)
    }

    func testResetPasswordCallsPasswordsResetByEmailStartIfPasswordsAreConfigured() async throws {
        let state = AuthInputState(
            config: .init(
                publicToken: "publicToken",
                products: [.passwords],
                passwordOptions: passwordConfig
            )
        )
        let viewModel = AuthInputViewModel(
            state: state,
            passwordClient: PasswordsSpy(callback: calledMethodCallback)
        )
        try await viewModel.resetPassword(email: "test@stytch.com")
        XCTAssert(calledMethod == .passwordsResetByEmailStart)
    }

    func testContinueWithPhoneCallsOTPLoginOrCreate() async throws {
        let state = AuthInputState(
            config: .init(
                publicToken: "publicToken",
                products: []
            )
        )
        let viewModel = AuthInputViewModel(
            state: state,
            otpClient: OTPSpy(callback: calledMethodCallback)
        )
        _ = try await viewModel.continueWithPhone(phone: "", formattedPhone: "")
        XCTAssert(calledMethod == .otpLoginOrCreate)
    }

    // getUserIntent is intentionally not tested since it's just fetching data from the API. But we can at least test the mapping of results -> intent
    func testUserTypeToPasswordIntentMappingWorksAsIntended() {
        XCTAssert(UserSearchResponse(userType: .new).userType.passwordIntent == .signup)
        XCTAssert(UserSearchResponse(userType: .password).userType.passwordIntent == .login)
        XCTAssert(UserSearchResponse(userType: .passwordless).userType.passwordIntent == nil)
    }
}

struct UserSearchRequest: Decodable {
    let email: String
}
