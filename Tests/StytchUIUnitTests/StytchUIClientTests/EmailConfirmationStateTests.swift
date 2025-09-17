import XCTest
@testable import StytchCore
@testable import StytchUI

final class EmailConfirmationStateTests: BaseTestCase {
    let config: StytchUIClient.Configuration = .init(
        stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
        products: [.emailMagicLinks]
    )

    func testForgotPasswordStateMethodsGenerateExpectedState() async throws {
        let forgotPassword = EmailConfirmationState.forgotPassword(config: config, email: "test@stytch.com") {}
        XCTAssert(forgotPassword.title == LocalizationManager.stytch_b2c_password_forgot)
        XCTAssert(forgotPassword.infoComponents == [
            .string(LocalizationManager.stytch_b2c_email_confirmation_link_to_reset_password_sent),
            .bold(.string("test@stytch.com")),
        ])
        XCTAssert(forgotPassword.secondaryAction == nil)
    }

    func testCheckYourEmailStateMethodsGenerateExpectedState() async throws {
        let checkYourEmail = EmailConfirmationState.checkYourEmail(config: config, email: "test@stytch.com") {}
        XCTAssert(checkYourEmail.title == .checkEmail)
        XCTAssert(checkYourEmail.infoComponents == [.string(.loginLinkSentToYou), .bold(.string("test@stytch.com"))])
        XCTAssert(checkYourEmail.secondaryAction == nil)
    }

    func testCheckYourEmailCreatePWInsteadStateMethodsGenerateExpectedState() async throws {
        let checkYourEmailCreatePWInstead = EmailConfirmationState.checkYourEmailCreatePasswordInstead(config: config, email: "test@stytch.com") {}
        XCTAssert(checkYourEmailCreatePWInstead.title == .checkEmail)
        XCTAssert(checkYourEmailCreatePWInstead.infoComponents == [.string(.loginLinkSentToYou), .bold(.string("test@stytch.com"))])
        XCTAssert(checkYourEmailCreatePWInstead.secondaryAction?.title == LocalizationManager.stytch_b2c_create_password_instead)
        XCTAssert(checkYourEmailCreatePWInstead.secondaryAction?.action == .didTapCreatePassword(email: "test@stytch.com"))
    }

    func testCheckYourEmailResetStateMethodsGenerateExpectedState() async throws {
        let checkYourEmailReset = EmailConfirmationState.checkYourEmailResetPassword(config: config, email: "test@stytch.com") {}
        XCTAssert(checkYourEmailReset.title == .checkEmailForNewPassword)
        XCTAssert(checkYourEmailReset.infoComponents == [
            .string(.loginLinkSentToYou),
            .bold(.string("test@stytch.com")),
            .string(LocalizationManager.stytch_b2c_email_confirmation_to_create_password),
        ])
        XCTAssert(checkYourEmailReset.secondaryAction == nil)
    }

    func testCheckYourEmailResetReturningStateMethodsGenerateExpectedState() async throws {
        let checkYourEmailResetReturning = EmailConfirmationState.checkYourEmailResetReturning(config: config, email: "test@stytch.com") {}
        XCTAssert(checkYourEmailResetReturning.title == .checkEmailForNewPassword)
        XCTAssert(checkYourEmailResetReturning.infoComponents == [
            .string(LocalizationManager.stytch_b2c_email_confirmation_make_sure_acount_secure),
            .bold(.string("test@stytch.com")),
        ])
        XCTAssert(checkYourEmailResetReturning.secondaryAction?.title == .loginWithoutPassword)
        XCTAssert(checkYourEmailResetReturning.secondaryAction?.action == .didTapLoginWithoutPassword(email: "test@stytch.com"))
    }

    func testEmailConfirmationStateCheckYourEmailResetBreachedMethodsGenerateExpectedState() async throws {
        let checkYourEmailResetBreached = EmailConfirmationState.checkYourEmailResetBreached(config: config, email: "test@stytch.com") {}
        XCTAssert(checkYourEmailResetBreached.title == .checkEmailForNewPassword)
        XCTAssert(checkYourEmailResetBreached.infoComponents == [
            .string(LocalizationManager.stytch_b2c_email_confirmation_password_breach),
            .bold(.string("test@stytch.com")),
            .string(LocalizationManager.stytch_b2c_email_confirmation_to_reset_password),
        ])
        XCTAssert(checkYourEmailResetBreached.secondaryAction?.title == .loginWithoutPassword)
        XCTAssert(checkYourEmailResetBreached.secondaryAction?.action == .didTapLoginWithoutPassword(email: "test@stytch.com"))
    }
}
