import XCTest
@testable import StytchCore
@testable import StytchUI

final class ActionableInfoViewModelTests: BaseTestCase {
    var calledMethod: CalledMethod?

    let magicLinkConfig: StytchUIClient.Configuration.MagicLink = .init(
        loginMagicLinkUrl: .init(string: "myapp://test-login"),
        loginExpiration: 123,
        loginTemplateId: "login-template-id",
        signupMagicLinkUrl: .init(string: "myapp://test-signup"),
        signupExpiration: 456,
        signupTemplateId: "signup-template-id"
    )

    let passwordConfig: StytchUIClient.Configuration.Password = .init(
        loginURL: .init(string: "myapp://test-login"),
        loginExpiration: 123,
        resetPasswordURL: .init(string: "myapp://test-reset"),
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
        let state: ActionableInfoState = .init(
            config: .init(
                publicToken: "",
                products: .init(),
                session: .init(sessionDuration: 123)
            ),
            email: "test@stytch.com",
            title: "Some ATitle",
            infoComponents: [],
            actionComponents: [],
            secondaryAction: nil
        ) {}
        let viewModel = ActionableInfoViewModel(
            state: state,
            passwordClient: PasswordsSpy(callback: calledMethodCallback),
            magicLinksClient: MagicLinksSpy(callback: calledMethodCallback)
        )
        XCTAssert(viewModel.sessionDuration.rawValue == 123)
    }

    func testSessionDurationMinutesReadsFromDefaultWhenNotConfigured() {
        let state: ActionableInfoState = .init(
            config: .init(
                publicToken: "",
                products: .init()
            ),
            email: "test@stytch.com",
            title: "Some ATitle",
            infoComponents: [],
            actionComponents: [],
            secondaryAction: nil
        ) {}
        let viewModel = ActionableInfoViewModel(
            state: state,
            passwordClient: PasswordsSpy(callback: calledMethodCallback),
            magicLinksClient: MagicLinksSpy(callback: calledMethodCallback)
        )
        XCTAssert(viewModel.sessionDuration == Minutes.defaultSessionDuration)
    }

    func testCreatesCorrectResetByEmailStartParams() {
        let state: ActionableInfoState = .init(
            config: .init(
                publicToken: "",
                products: .init()
            ),
            email: "test@stytch.com",
            title: "Some ATitle",
            infoComponents: [],
            actionComponents: [],
            secondaryAction: nil
        ) {}
        let viewModel = ActionableInfoViewModel(
            state: state,
            passwordClient: PasswordsSpy(callback: calledMethodCallback),
            magicLinksClient: MagicLinksSpy(callback: calledMethodCallback)
        )
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
        let state: ActionableInfoState = .init(
            config: .init(
                publicToken: "",
                products: .init()
            ),
            email: "test@stytch.com",
            title: "Some ATitle",
            infoComponents: [],
            actionComponents: [],
            secondaryAction: nil
        ) {}
        let viewModel = ActionableInfoViewModel(
            state: state,
            passwordClient: PasswordsSpy(callback: calledMethodCallback),
            magicLinksClient: MagicLinksSpy(callback: calledMethodCallback)
        )
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

    func testLoginWithoutPasswordDoesNothingIfMagicLinksAreNotConfigured() async throws {
        let state: ActionableInfoState = .init(
            config: .init(
                publicToken: "",
                products: .init()
            ),
            email: "test@stytch.com",
            title: "Some ATitle",
            infoComponents: [],
            actionComponents: [],
            secondaryAction: nil
        ) {}
        let viewModel = ActionableInfoViewModel(
            state: state,
            passwordClient: PasswordsSpy(callback: calledMethodCallback),
            magicLinksClient: MagicLinksSpy(callback: calledMethodCallback)
        )
        try await viewModel.loginWithoutPassword(email: "")
        XCTAssert(calledMethod == nil)
    }

    func testLoginWithoutPasswordCallsMagicLinksLoginOrCreateIfMagicLinksAreConfigured() async throws {
        let state: ActionableInfoState = .init(
            config: .init(
                publicToken: "",
                products: .init(
                    magicLink: .init()
                )
            ),
            email: "test@stytch.com",
            title: "Some ATitle",
            infoComponents: [],
            actionComponents: [],
            secondaryAction: nil
        ) {}
        let viewModel = ActionableInfoViewModel(
            state: state,
            passwordClient: PasswordsSpy(callback: calledMethodCallback),
            magicLinksClient: MagicLinksSpy(callback: calledMethodCallback)
        )
        try await viewModel.loginWithoutPassword(email: "")
        XCTAssert(calledMethod == .magicLinksLoginOrCreate)
    }

    func testForgotPasswordDoesNothingIfPasswordsAreNotConfigured() async throws {
        let state: ActionableInfoState = .init(
            config: .init(
                publicToken: "",
                products: .init()
            ),
            email: "test@stytch.com",
            title: "Some ATitle",
            infoComponents: [],
            actionComponents: [],
            secondaryAction: nil
        ) {}
        let viewModel = ActionableInfoViewModel(
            state: state,
            passwordClient: PasswordsSpy(callback: calledMethodCallback),
            magicLinksClient: MagicLinksSpy(callback: calledMethodCallback)
        )
        try await viewModel.forgotPassword(email: "test@stytch.com")
        XCTAssert(calledMethod == nil)
    }

    func testForgotPasswordCallsPasswordResetByEmailStartAndSetsPendingEmailIfPasswordsAreConfigured() async throws {
        let state: ActionableInfoState = .init(
            config: .init(
                publicToken: "",
                products: .init(
                    password: .init()
                )
            ),
            email: "test@stytch.com",
            title: "Some ATitle",
            infoComponents: [],
            actionComponents: [],
            secondaryAction: nil
        ) {}
        let viewModel = ActionableInfoViewModel(
            state: state,
            passwordClient: PasswordsSpy(callback: calledMethodCallback),
            magicLinksClient: MagicLinksSpy(callback: calledMethodCallback)
        )
        try await viewModel.forgotPassword(email: "test@stytch.com")
        XCTAssert(calledMethod == .passwordsResetByEmailStart)
        XCTAssert(StytchUIClient.pendingResetEmail == "test@stytch.com")
    }
}
