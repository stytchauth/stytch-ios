import XCTest
@testable import StytchCore
@testable import StytchUI

final class ActionableInfoViewModelTests: BaseTestCase {
    var calledMethod: CalledMethod? = nil
    func calledMethodCallback(method: CalledMethod) {
        calledMethod = method
    }

    override func setUp() async throws {
        calledMethod = nil
        StytchUIClient.pendingResetEmail = nil
    }

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
            secondaryAction: nil,
            retryAction: {}
        )
        let vm: ActionableInfoViewModel = ActionableInfoViewModel.init(
            state: state,
            passwordClient: PasswordsSpy(callback: calledMethodCallback),
            magicLinksClient: MagicLinksSpy(callback: calledMethodCallback)
        )
        XCTAssert(vm.sessionDuration.rawValue == 123)
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
            secondaryAction: nil,
            retryAction: {}
        )
        let vm: ActionableInfoViewModel = ActionableInfoViewModel.init(
            state: state,
            passwordClient: PasswordsSpy(callback: calledMethodCallback),
            magicLinksClient: MagicLinksSpy(callback: calledMethodCallback)
        )
        XCTAssert(vm.sessionDuration == Minutes.defaultSessionDuration)
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
            secondaryAction: nil,
            retryAction: {}
        )
        let vm: ActionableInfoViewModel = ActionableInfoViewModel.init(
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
        let result = vm.params(email: "test@stytch.com", password: passwordConfig)
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
            secondaryAction: nil,
            retryAction: {}
        )
        let vm: ActionableInfoViewModel = ActionableInfoViewModel.init(
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
        let result = vm.params(email: "test@stytch.com", magicLink: magicLinkConfig)
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
            secondaryAction: nil,
            retryAction: {}
        )
        let vm: ActionableInfoViewModel = ActionableInfoViewModel.init(
            state: state,
            passwordClient: PasswordsSpy(callback: calledMethodCallback),
            magicLinksClient: MagicLinksSpy(callback: calledMethodCallback)
        )
        try await vm.loginWithoutPassword(email: "")
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
            secondaryAction: nil,
            retryAction: {}
        )
        let vm: ActionableInfoViewModel = ActionableInfoViewModel.init(
            state: state,
            passwordClient: PasswordsSpy(callback: calledMethodCallback),
            magicLinksClient: MagicLinksSpy(callback: calledMethodCallback)
        )
        try await vm.loginWithoutPassword(email: "")
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
            secondaryAction: nil,
            retryAction: {}
        )
        let vm: ActionableInfoViewModel = ActionableInfoViewModel.init(
            state: state,
            passwordClient: PasswordsSpy(callback: calledMethodCallback),
            magicLinksClient: MagicLinksSpy(callback: calledMethodCallback)
        )
        try await vm.forgotPassword(email: "test@stytch.com")
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
            secondaryAction: nil,
            retryAction: {}
        )
        let vm: ActionableInfoViewModel = ActionableInfoViewModel.init(
            state: state,
            passwordClient: PasswordsSpy(callback: calledMethodCallback),
            magicLinksClient: MagicLinksSpy(callback: calledMethodCallback)
        )
        try await vm.forgotPassword(email: "test@stytch.com")
        XCTAssert(calledMethod == .passwordsResetByEmailStart)
        XCTAssert(StytchUIClient.pendingResetEmail == "test@stytch.com")
    }

    func testActionaableInfoStateMethodsGenerateExpectedState() async throws {
        let config: StytchUIClient.Configuration = .init(
            publicToken: "",
            products: .init()
        )
        let forgotPassword = ActionableInfoState.forgotPassword(
            config: config,
            email: "test@stytch.com",
            retryAction: {}
        )
        XCTAssert(forgotPassword.title == NSLocalizedString("stytch.aiForgotPW", value: "Forgot password?", comment: ""))
        XCTAssert(forgotPassword.infoComponents == [
            .string(NSLocalizedString("stytch.linkToResetPWSent", value: "A link to reset your password was sent to you at ", comment: "")),
            .bold(.string("test@stytch.com")),
        ])
        XCTAssert(forgotPassword.actionComponents == .didntGetItResendEmail)
        XCTAssert(forgotPassword.secondaryAction == nil)

        let checkYourEmail = ActionableInfoState.checkYourEmail(
            config: config,
            email: "test@stytch.com",
            retryAction: {}
        )
        XCTAssert(checkYourEmail.title == .checkEmail)
        XCTAssert(checkYourEmail.infoComponents == [.string(.loginLinkSentToYou), .bold(.string("test@stytch.com")), "."])
        XCTAssert(checkYourEmail.actionComponents == .didntGetItResendEmail)
        XCTAssert(checkYourEmail.secondaryAction == nil)

        let checkYourEmailCreatePWInstead = ActionableInfoState.checkYourEmailCreatePWInstead(
            config: config,
            email: "test@stytch.com",
            retryAction: {}
        )
        XCTAssert(checkYourEmailCreatePWInstead.title == .checkEmail)
        XCTAssert(checkYourEmailCreatePWInstead.infoComponents == [.string(.loginLinkSentToYou), .bold(.string("test@stytch.com")), "."])
        XCTAssert(checkYourEmailCreatePWInstead.actionComponents == .didntGetItResendEmail)
        XCTAssert(checkYourEmailCreatePWInstead.secondaryAction?.title == NSLocalizedString("stytch.aiCreatePWInstead", value: "Create a password instead", comment: ""))
        XCTAssert(checkYourEmailCreatePWInstead.secondaryAction?.action == .didTapCreatePassword(email: "test@stytch.com"))

        let checkYourEmailReset = ActionableInfoState.checkYourEmailReset(
            config: config,
            email: "test@stytch.com",
            retryAction: {}
        )
        XCTAssert(checkYourEmailReset.title == .checkEmailForNewPW)
        XCTAssert(checkYourEmailReset.infoComponents == [
            .string(.loginLinkSentToYou),
            .bold(.string("test@stytch.com")),
            .string(NSLocalizedString("stytch.toCreatePW", value: " to create a password for your account.", comment: "")),
        ])
        XCTAssert(checkYourEmailReset.actionComponents == .didntGetItResendEmail)
        XCTAssert(checkYourEmailReset.secondaryAction == nil)

        let checkYourEmailResetReturning = ActionableInfoState.checkYourEmailResetReturning(
            config: config,
            email: "test@stytch.com",
            retryAction: {}
        )
        XCTAssert(checkYourEmailResetReturning.title == .checkEmailForNewPW)
        XCTAssert(checkYourEmailResetReturning.infoComponents == [
            .string(NSLocalizedString("stytch.aiMakeSureAcctSecure", value: "We want to make sure your account is secure and that it’s really you logging in. A login link was sent to you at ", comment: "")),
            .bold(.string("test@stytch.com")),
            .string(.period),
        ])
        XCTAssert(checkYourEmailResetReturning.actionComponents == .didntGetItResendEmail)
        XCTAssert(checkYourEmailResetReturning.secondaryAction?.title == .loginWithoutPW)
        XCTAssert(checkYourEmailResetReturning.secondaryAction?.action == .didTapLoginWithoutPassword(email: "test@stytch.com"))

        let checkYourEmailResetBreached = ActionableInfoState.checkYourEmailResetBreached(
            config: config,
            email: "test@stytch.com",
            retryAction: {}
        )
        XCTAssert(checkYourEmailResetBreached.title == .checkEmailForNewPW)
        XCTAssert(checkYourEmailResetBreached.infoComponents == [
            .string(NSLocalizedString("stytch.aiPWBreach", value: "A different site where you use the same password had a security issue recently. For your safety, an email was sent to you at ", comment: "")),
            .bold(.string("test@stytch.com")),
            .string(NSLocalizedString("stytch.toResetPW", value: " to reset your password.", comment: "")),
        ])
        XCTAssert(checkYourEmailResetBreached.actionComponents == .didntGetItResendEmail)
        XCTAssert(checkYourEmailResetBreached.secondaryAction?.title == .loginWithoutPW)
        XCTAssert(checkYourEmailResetBreached.secondaryAction?.action == .didTapLoginWithoutPassword(email: "test@stytch.com"))
    }
}
