import XCTest
@testable import StytchCore
@testable import StytchUI

final class ActionableInfoStateTests: BaseTestCase {
    let config: StytchUIClient.Configuration = .init(
        publicToken: "publicToken",
        products: [.emailMagicLinks]
    )

    func testActionableInfoForgotPasswordStateMethodsGenerateExpectedState() async throws {
        let forgotPassword = ActionableInfoState.forgotPassword(config: config, email: "test@stytch.com") {}
        XCTAssert(forgotPassword.title == NSLocalizedString("stytch.aiForgotPW", value: "Forgot password?", comment: ""))
        XCTAssert(forgotPassword.infoComponents == [
            .string(NSLocalizedString("stytch.linkToResetPWSent", value: "A link to reset your password was sent to you at ", comment: "")),
            .bold(.string("test@stytch.com")),
        ])
        XCTAssert(forgotPassword.actionComponents == .didntGetItResendEmail)
        XCTAssert(forgotPassword.secondaryAction == nil)
    }

    func testActionableInfoCheckYourEmailStateMethodsGenerateExpectedState() async throws {
        let checkYourEmail = ActionableInfoState.checkYourEmail(config: config, email: "test@stytch.com") {}
        XCTAssert(checkYourEmail.title == .checkEmail)
        XCTAssert(checkYourEmail.infoComponents == [.string(.loginLinkSentToYou), .bold(.string("test@stytch.com")), "."])
        XCTAssert(checkYourEmail.actionComponents == .didntGetItResendEmail)
        XCTAssert(checkYourEmail.secondaryAction == nil)
    }

    func testActionableInfoCheckYourEmailCreatePWInsteadStateMethodsGenerateExpectedState() async throws {
        let checkYourEmailCreatePWInstead = ActionableInfoState.checkYourEmailCreatePWInstead(config: config, email: "test@stytch.com") {}
        XCTAssert(checkYourEmailCreatePWInstead.title == .checkEmail)
        XCTAssert(checkYourEmailCreatePWInstead.infoComponents == [.string(.loginLinkSentToYou), .bold(.string("test@stytch.com")), "."])
        XCTAssert(checkYourEmailCreatePWInstead.actionComponents == .didntGetItResendEmail)
        XCTAssert(checkYourEmailCreatePWInstead.secondaryAction?.title == NSLocalizedString("stytch.aiCreatePWInstead", value: "Create a password instead", comment: ""))
        XCTAssert(checkYourEmailCreatePWInstead.secondaryAction?.action == .didTapCreatePassword(email: "test@stytch.com"))
    }

    func testActionableInfoCheckYourEmailResetStateMethodsGenerateExpectedState() async throws {
        let checkYourEmailReset = ActionableInfoState.checkYourEmailReset(config: config, email: "test@stytch.com") {}
        XCTAssert(checkYourEmailReset.title == .checkEmailForNewPW)
        XCTAssert(checkYourEmailReset.infoComponents == [
            .string(.loginLinkSentToYou),
            .bold(.string("test@stytch.com")),
            .string(NSLocalizedString("stytch.toCreatePW", value: " to create a password for your account.", comment: "")),
        ])
        XCTAssert(checkYourEmailReset.actionComponents == .didntGetItResendEmail)
        XCTAssert(checkYourEmailReset.secondaryAction == nil)
    }

    func testActionableInfoCheckYourEmailResetReturningStateMethodsGenerateExpectedState() async throws {
        let checkYourEmailResetReturning = ActionableInfoState.checkYourEmailResetReturning(config: config, email: "test@stytch.com") {}
        XCTAssert(checkYourEmailResetReturning.title == .checkEmailForNewPW)
        XCTAssert(checkYourEmailResetReturning.infoComponents == [
            .string(NSLocalizedString("stytch.aiMakeSureAcctSecure", value: "We want to make sure your account is secure and that it’s really you logging in. A login link was sent to you at ", comment: "")),
            .bold(.string("test@stytch.com")),
            .string(.period),
        ])
        XCTAssert(checkYourEmailResetReturning.actionComponents == .didntGetItResendEmail)
        XCTAssert(checkYourEmailResetReturning.secondaryAction?.title == .loginWithoutPW)
        XCTAssert(checkYourEmailResetReturning.secondaryAction?.action == .didTapLoginWithoutPassword(email: "test@stytch.com"))
    }

    func testActionableInfoStateCheckYourEmailResetBreachedMethodsGenerateExpectedState() async throws {
        let checkYourEmailResetBreached = ActionableInfoState.checkYourEmailResetBreached(config: config, email: "test@stytch.com") {}
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
