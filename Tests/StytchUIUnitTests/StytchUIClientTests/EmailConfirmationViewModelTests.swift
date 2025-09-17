import XCTest
@testable import StytchCore
@testable import StytchUI

final class EmailConfirmationViewModelTests: BaseTestCase {
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
        StytchUIClient.pendingResetEmail = nil
    }

    func testSessionDurationMinutesReadsFromConfig() {
        let config: StytchUIClient.Configuration = .init(
            stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
            products: [.emailMagicLinks]
        )

        let state: EmailConfirmationState = .init(
            config: config,
            email: "test@stytch.com",
            title: "Some ATitle",
            infoComponents: [],
            actionComponents: [],
            secondaryAction: nil
        ) {}
        _ = EmailConfirmationViewModel(
            state: state,
            passwordClient: PasswordsSpy(callback: calledMethodCallback),
            magicLinksClient: MagicLinksSpy(callback: calledMethodCallback)
        )
        XCTAssert(state.config.stytchClientConfiguration.defaultSessionDuration == 5)
    }

    func testCreatesCorrectResetByEmailStartParams() {
        let config: StytchUIClient.Configuration = .init(
            stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
            products: [.passwords],
            passwordOptions: passwordConfig
        )

        let state: EmailConfirmationState = .init(
            config: config,
            email: "test@stytch.com",
            title: "Some ATitle",
            infoComponents: [],
            actionComponents: [],
            secondaryAction: nil
        ) {}
        let viewModel = EmailConfirmationViewModel(
            state: state,
            passwordClient: PasswordsSpy(callback: calledMethodCallback),
            magicLinksClient: MagicLinksSpy(callback: calledMethodCallback)
        )
        let expected: StytchClient.Passwords.ResetByEmailStartParameters = .init(
            email: "test@stytch.com",
            loginRedirectUrl: config.redirectUrl,
            loginExpirationMinutes: passwordConfig.loginExpiration,
            resetPasswordRedirectUrl: config.redirectUrl,
            resetPasswordExpirationMinutes: passwordConfig.resetPasswordExpiration,
            resetPasswordTemplateId: passwordConfig.resetPasswordTemplateId
        )
        let result = viewModel.params(email: "test@stytch.com", password: passwordConfig)
        XCTAssert(result == expected)
    }

    func testCreatesCorrectMagicLinkParams() {
        let config: StytchUIClient.Configuration = .init(
            stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
            products: [.emailMagicLinks],
            magicLinkOptions: magicLinkConfig
        )

        let state: EmailConfirmationState = .init(
            config: config,
            email: "test@stytch.com",
            title: "Some ATitle",
            infoComponents: [],
            actionComponents: [],
            secondaryAction: nil
        ) {}
        let viewModel = EmailConfirmationViewModel(
            state: state,
            passwordClient: PasswordsSpy(callback: calledMethodCallback),
            magicLinksClient: MagicLinksSpy(callback: calledMethodCallback)
        )
        let expected: StytchClient.MagicLinks.Email.Parameters = .init(
            email: "test@stytch.com",
            loginMagicLinkUrl: config.redirectUrl,
            loginExpirationMinutes: magicLinkConfig.loginExpiration,
            loginTemplateId: magicLinkConfig.loginTemplateId,
            signupMagicLinkUrl: config.redirectUrl,
            signupExpirationMinutes: magicLinkConfig.signupExpiration,
            signupTemplateId: magicLinkConfig.signupTemplateId
        )
        let result = viewModel.params(email: "test@stytch.com", magicLink: magicLinkConfig)
        XCTAssert(result == expected)
    }

    func testLoginWithoutPasswordDoesNothingIfMagicLinksAreNotConfigured() async throws {
        let config: StytchUIClient.Configuration = .init(
            stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
            products: []
        )

        let state: EmailConfirmationState = .init(
            config: config,
            email: "test@stytch.com",
            title: "Some ATitle",
            infoComponents: [],
            actionComponents: [],
            secondaryAction: nil
        ) {}
        let viewModel = EmailConfirmationViewModel(
            state: state,
            passwordClient: PasswordsSpy(callback: calledMethodCallback),
            magicLinksClient: MagicLinksSpy(callback: calledMethodCallback)
        )
        try await viewModel.loginWithoutPassword(email: "")
        XCTAssert(calledMethod == nil)
    }

    func testLoginWithoutPasswordCallsMagicLinksLoginOrCreateIfMagicLinksAreConfigured() async throws {
        let config: StytchUIClient.Configuration = .init(
            stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
            products: [.emailMagicLinks],
            magicLinkOptions: magicLinkConfig
        )

        let state: EmailConfirmationState = .init(
            config: config,
            email: "test@stytch.com",
            title: "Some ATitle",
            infoComponents: [],
            actionComponents: [],
            secondaryAction: nil
        ) {}
        let viewModel = EmailConfirmationViewModel(
            state: state,
            passwordClient: PasswordsSpy(callback: calledMethodCallback),
            magicLinksClient: MagicLinksSpy(callback: calledMethodCallback)
        )
        try await viewModel.loginWithoutPassword(email: "")
        XCTAssert(calledMethod == .magicLinksLoginOrCreate)
    }

    func testForgotPasswordDoesNothingIfPasswordsAreNotConfigured() async throws {
        let config: StytchUIClient.Configuration = .init(
            stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
            products: []
        )

        let state: EmailConfirmationState = .init(
            config: config,
            email: "test@stytch.com",
            title: "Some ATitle",
            infoComponents: [],
            actionComponents: [],
            secondaryAction: nil
        ) {}
        let viewModel = EmailConfirmationViewModel(
            state: state,
            passwordClient: PasswordsSpy(callback: calledMethodCallback),
            magicLinksClient: MagicLinksSpy(callback: calledMethodCallback)
        )
        try await viewModel.forgotPassword(email: "test@stytch.com")
        XCTAssert(calledMethod == nil)
    }

    func testForgotPasswordCallsPasswordResetByEmailStartAndSetsPendingEmailIfPasswordsAreConfigured() async throws {
        let config: StytchUIClient.Configuration = .init(
            stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
            products: [.passwords, .emailMagicLinks],
            passwordOptions: passwordConfig,
            magicLinkOptions: magicLinkConfig
        )

        let state: EmailConfirmationState = .init(
            config: config,
            email: "test@stytch.com",
            title: "Some ATitle",
            infoComponents: [],
            actionComponents: [],
            secondaryAction: nil
        ) {}
        let viewModel = EmailConfirmationViewModel(
            state: state,
            passwordClient: PasswordsSpy(callback: calledMethodCallback),
            magicLinksClient: MagicLinksSpy(callback: calledMethodCallback)
        )
        try await viewModel.forgotPassword(email: "test@stytch.com")
        XCTAssert(calledMethod == .passwordsResetByEmailStart)
        XCTAssert(StytchUIClient.pendingResetEmail == "test@stytch.com")
    }
}
