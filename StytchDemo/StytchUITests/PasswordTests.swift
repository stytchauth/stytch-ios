import XCTest

final class PasswordTests: XCTestCase {
    private let app = XCUIApplication()
    private let email = generateNewEmail()
    private let password = generatePassword()
    private lazy var emailField = app.scrollViews.otherElements.textFields["example@company.com"]
    private lazy var continueButton = app.scrollViews.otherElements.buttons["Continue"]
    private lazy var createAccountTitle = app.scrollViews.otherElements.staticTexts["Create account"]
    private lazy var logInTitle = app.scrollViews.otherElements.staticTexts["Log in"]
    private lazy var emailInputLabel = app.scrollViews.otherElements.staticTexts["Email"]
    private lazy var emailInput = app.scrollViews.otherElements.textFields[email]
    private lazy var passwordInputLabel = app.scrollViews.otherElements.staticTexts["Password"]
    private lazy var secureTextInput = app.scrollViews.otherElements.secureTextFields.element(boundBy: 0)
    private lazy var secureEntryToggleButton = app.scrollViews.otherElements.buttons["show"]
    private lazy var forgotPasswordButton = app.scrollViews.otherElements.buttons["Forgot password?"]

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchEnvironment["config"] = "password"
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    @MainActor func testPassword() throws {
        // test new user
        emailField.tap()
        emailField.typeText(email)
        continueButton.tap()

        expectation(for: NSPredicate(format: "exists == true"), evaluatedWith: createAccountTitle)

        waitForExpectations(timeout: 5)

        XCTAssertTrue(createAccountTitle.exists)
        XCTAssertTrue(emailInputLabel.exists)
        XCTAssertTrue(emailInput.exists)
        XCTAssertTrue(passwordInputLabel.exists)
        XCTAssertTrue(secureTextInput.exists)
        XCTAssertTrue(secureEntryToggleButton.exists)
        XCTAssertTrue(continueButton.exists)
        XCTAssertTrue(!continueButton.isEnabled)

        secureTextInput.typeText(password)

        XCTAssertTrue(continueButton.isEnabled)

        continueButton.tap()

        try tearDownWithError()
        try setUpWithError()

        // test existing user
        emailField.tap()
        emailField.typeText(email)
        continueButton.tap()

        expectation(for: NSPredicate(format: "exists == true"), evaluatedWith: logInTitle)

        waitForExpectations(timeout: 5)

        XCTAssertTrue(logInTitle.exists)
        XCTAssertTrue(emailInputLabel.exists)
        XCTAssertTrue(emailInput.exists)
        XCTAssertTrue(passwordInputLabel.exists)
        XCTAssertTrue(secureTextInput.exists)
        XCTAssertTrue(secureEntryToggleButton.exists)
        XCTAssertTrue(continueButton.exists)
        XCTAssertTrue(!continueButton.isEnabled)

        secureTextInput.typeText(password)

        XCTAssertTrue(continueButton.isEnabled)

        continueButton.tap()
    }
}
