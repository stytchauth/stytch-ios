import XCTest

final class MagicLinkTests: XCTestCase {
    private let app = XCUIApplication()
    private let email = generateNewEmail()
    private lazy var emailField = app.scrollViews.otherElements.textFields["example@company.com"]
    private lazy var continueButton = app.scrollViews.otherElements.buttons["Continue"]
    private lazy var errorLabel = app.scrollViews.otherElements.staticTexts["Invalid email address, please try again."]
    private lazy var magicLinkTitleLabel = app.staticTexts["Check your email"]
    private lazy var magicLinkDescriptionLabel = app.staticTexts["A login link was sent to you at \(email)."]
    private lazy var magicLinkResendLabel = app.staticTexts["Didn't get it? Resend email"]
    private lazy var magicLinkResendCancelButton = app.alerts["Resend link"].scrollViews.otherElements.buttons["Cancel"]
    private lazy var magicLinkResendButton = app.alerts["Resend link"].scrollViews.otherElements.buttons["Resend"]

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchEnvironment["config"] = "magiclink"
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    func testNoEmailInput() {
        XCTAssertTrue(emailField.exists)
        XCTAssertTrue(continueButton.exists)
        XCTAssertTrue(!continueButton.isEnabled)
    }

    func testInvalidEmail() {
        emailField.tap()
        emailField.typeText("invalidemail")

        XCTAssertTrue(!continueButton.isEnabled)
    }

    func testInvalidEmailError() {
        XCTAssertTrue(!errorLabel.exists)

        emailField.tap()
        emailField.typeText("invalidemail@example.com1")

        XCTAssertTrue(errorLabel.exists)
    }

    @MainActor func testValidEmail() {
        emailField.tap()
        emailField.typeText(email)

        XCTAssertTrue(continueButton.isEnabled)

        continueButton.tap()

        expectation(for: NSPredicate(format: "exists == true"), evaluatedWith: magicLinkTitleLabel)

        waitForExpectations(timeout: 5)

        XCTAssertTrue(magicLinkTitleLabel.exists)
        XCTAssertTrue(magicLinkDescriptionLabel.exists)
        XCTAssertTrue(magicLinkResendLabel.exists)

        magicLinkResendLabel.tap()
        app.alerts["Resend link"].scrollViews.otherElements.buttons["Cancel"].tap()

        magicLinkResendLabel.tap()
        app.alerts["Resend link"].scrollViews.otherElements.buttons["Send link"].tap()

        XCTAssertTrue(magicLinkTitleLabel.exists)
        XCTAssertTrue(magicLinkDescriptionLabel.exists)
        XCTAssertTrue(magicLinkResendLabel.exists)
    }
}
