import XCTest

final class MagicLinkPasswordTests: XCTestCase {
    private let app = XCUIApplication()
    private let emailMagicLink = generateNewEmail()
    private let emailPassword = generateNewEmail()
    private let password = generatePassword()
    private lazy var emailField = app.scrollViews.otherElements.textFields["example@company.com"]
    private lazy var continueButton = app.scrollViews.otherElements.buttons["Continue"]
    private lazy var newUserTitleLabel = app.staticTexts["Choose how you would like to create your account."]
    private lazy var magicLinkButton = app.scrollViews.otherElements.buttons["Email me a login link"]
    private lazy var orSeparator = app.scrollViews.otherElements.staticTexts["or"]
    private lazy var newUserPasswordLabel = app.scrollViews.otherElements.staticTexts["Finish creating your account by setting a password."]
    private lazy var emailInputLabel = app.scrollViews.otherElements.staticTexts["Email"]
    private lazy var emailInput = app.scrollViews.otherElements.textFields[emailMagicLink]
    private lazy var passwordInputLabel = app.scrollViews.otherElements.staticTexts["Password"]
    private lazy var secureTextInput = app.scrollViews.otherElements.secureTextFields.element(boundBy: 0)
    private lazy var secureEntryToggleButton = app.scrollViews.otherElements.buttons["show"]
    private lazy var magicLinkTitleLabel = app.staticTexts["Check your email"]
    private lazy var magicLinkDescriptionLabel = app.staticTexts["A login link was sent to you at \(emailMagicLink)."]
    private lazy var magicLinkResendLabel = app.staticTexts["Didn't get it? Resend email"]
    private lazy var magicLinkResendCancelButton = app.alerts["Resend link"].scrollViews.otherElements.buttons["Cancel"]
    private lazy var magicLinkResendButton = app.alerts["Resend link"].scrollViews.otherElements.buttons["Resend"]

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchEnvironment["config"] = "magiclinkpassword"
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    @MainActor func testNewUserMagicLink() {
        emailField.tap()
        emailField.typeText(emailMagicLink)
        continueButton.tap()

        expectation(for: NSPredicate(format: "exists == true"), evaluatedWith: newUserTitleLabel)

        waitForExpectations(timeout: 5)

        XCTAssertTrue(newUserTitleLabel.exists)
        XCTAssertTrue(magicLinkButton.exists)
        XCTAssertTrue(orSeparator.exists)
        XCTAssertTrue(newUserPasswordLabel.exists)
        XCTAssertTrue(emailInputLabel.exists)
        XCTAssertTrue(emailInput.exists)
        XCTAssertTrue(passwordInputLabel.exists)
        XCTAssertTrue(secureTextInput.exists)
        XCTAssertTrue(secureEntryToggleButton.exists)

        XCTAssertTrue(magicLinkButton.isEnabled)
        magicLinkButton.tap()

        expectation(for: NSPredicate(format: "exists == true"), evaluatedWith: magicLinkTitleLabel)

        waitForExpectations(timeout: 5)

        XCTAssertTrue(magicLinkTitleLabel.exists)
        XCTAssertTrue(magicLinkDescriptionLabel.exists)
        XCTAssertTrue(magicLinkResendLabel.exists)

        magicLinkResendLabel.tap()
        app.alerts["Resend link"].scrollViews.otherElements.buttons["Send link"].tap()
    }

    @MainActor func testNewUserPassword() {
        emailField.tap()
        emailField.typeText(emailPassword)
        continueButton.tap()

        expectation(for: NSPredicate(format: "exists == true"), evaluatedWith: secureTextInput)

        waitForExpectations(timeout: 5)

        secureTextInput.typeText(password)

        XCTAssertTrue(continueButton.isEnabled)

        continueButton.tap()
    }
}
