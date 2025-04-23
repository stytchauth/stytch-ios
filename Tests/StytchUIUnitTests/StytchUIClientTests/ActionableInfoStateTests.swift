import XCTest
@testable import StytchCore
@testable import StytchUI

final class ActionableInfoStateTests: BaseTestCase {
    let config: StytchUIClient.Configuration = .init(
        stytchClientConfiguration: .init(publicToken: "publicToken"),
        products: [.emailMagicLinks]
    )

    func testActionableInfoForgotPasswordStateMethodsGenerateExpectedState() async throws {
        let forgotPassword = ActionableInfoState.forgotPassword(config: config, email: "test@stytch.com") {}
        XCTAssert(forgotPassword.title == LocalizationManager.stytch_b2c_forgot_password)
        XCTAssert(forgotPassword.infoComponents == [
            .string(LocalizationManager.stytch_b2c_link_to_reset_password_sent),
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
        let checkYourEmailCreatePWInstead = ActionableInfoState.checkYourEmailCreatePasswordInstead(config: config, email: "test@stytch.com") {}
        XCTAssert(checkYourEmailCreatePWInstead.title == .checkEmail)
        XCTAssert(checkYourEmailCreatePWInstead.infoComponents == [.string(.loginLinkSentToYou), .bold(.string("test@stytch.com")), "."])
        XCTAssert(checkYourEmailCreatePWInstead.actionComponents == .didntGetItResendEmail)
        XCTAssert(checkYourEmailCreatePWInstead.secondaryAction?.title == LocalizationManager.stytch_b2c_create_password_instead)
        XCTAssert(checkYourEmailCreatePWInstead.secondaryAction?.action == .didTapCreatePassword(email: "test@stytch.com"))
    }

    func testActionableInfoCheckYourEmailResetStateMethodsGenerateExpectedState() async throws {
        let checkYourEmailReset = ActionableInfoState.checkYourEmailResetPassword(config: config, email: "test@stytch.com") {}
        XCTAssert(checkYourEmailReset.title == .checkEmailForNewPassword)
        XCTAssert(checkYourEmailReset.infoComponents == [
            .string(.loginLinkSentToYou),
            .bold(.string("test@stytch.com")),
            .string(LocalizationManager.stytch_b2c_to_create_password),
        ])
        XCTAssert(checkYourEmailReset.actionComponents == .didntGetItResendEmail)
        XCTAssert(checkYourEmailReset.secondaryAction == nil)
    }

    func testActionableInfoCheckYourEmailResetReturningStateMethodsGenerateExpectedState() async throws {
        let checkYourEmailResetReturning = ActionableInfoState.checkYourEmailResetReturning(config: config, email: "test@stytch.com") {}
        XCTAssert(checkYourEmailResetReturning.title == .checkEmailForNewPassword)
        XCTAssert(checkYourEmailResetReturning.infoComponents == [
            .string(LocalizationManager.stytch_b2c_make_sure_acount_secure),
            .bold(.string("test@stytch.com")),
            .string(.period),
        ])
        XCTAssert(checkYourEmailResetReturning.actionComponents == .didntGetItResendEmail)
        XCTAssert(checkYourEmailResetReturning.secondaryAction?.title == .loginWithoutPassword)
        XCTAssert(checkYourEmailResetReturning.secondaryAction?.action == .didTapLoginWithoutPassword(email: "test@stytch.com"))
    }

    func testActionableInfoStateCheckYourEmailResetBreachedMethodsGenerateExpectedState() async throws {
        let checkYourEmailResetBreached = ActionableInfoState.checkYourEmailResetBreached(config: config, email: "test@stytch.com") {}
        XCTAssert(checkYourEmailResetBreached.title == .checkEmailForNewPassword)
        XCTAssert(checkYourEmailResetBreached.infoComponents == [
            .string(LocalizationManager.stytch_b2c_password_breach),
            .bold(.string("test@stytch.com")),
            .string(LocalizationManager.stytch_b2c_to_reset_password),
        ])
        XCTAssert(checkYourEmailResetBreached.actionComponents == .didntGetItResendEmail)
        XCTAssert(checkYourEmailResetBreached.secondaryAction?.title == .loginWithoutPassword)
        XCTAssert(checkYourEmailResetBreached.secondaryAction?.action == .didTapLoginWithoutPassword(email: "test@stytch.com"))
    }
}
