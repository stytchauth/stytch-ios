import XCTest

final class MagicLinkTests: XCTestCase {
    private let app = XCUIApplication()
    private lazy var emailField = app.otherElements["emailInput"]
    private lazy var continueButton = app.buttons["continueButton"]
    private lazy var feedbackLabel = app.staticTexts["feedbackLabel"]
    private lazy var actionableInfoTitle = app.staticTexts["actionableInfoTitle"]
    private lazy var actionableInfoLabel = app.staticTexts["actionableInfoLabel"]
    private lazy var retryButton = app.buttons["retryButton"]
    private lazy var orSeparator = app.otherElements["orSeparator"]
    private lazy var secondaryButton = app.buttons["secondaryButton"]

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
        XCTAssertTrue(!feedbackLabel.exists)

        emailField.tap()
        emailField.typeText("invalidemail@example.com1")

        XCTAssertTrue(feedbackLabel.exists)
    }

    @MainActor func testValidEmail() {
        emailField.tap()
        emailField.typeText("test+validemail@stytch.com")

        XCTAssertTrue(continueButton.isEnabled)

        continueButton.tap()

        expectation(for: NSPredicate(format: "exists == true"), evaluatedWith: actionableInfoTitle)

        waitForExpectations(timeout: 3)

        XCTAssertTrue(actionableInfoTitle.exists)
        XCTAssertTrue(actionableInfoLabel.exists)
        XCTAssertTrue(retryButton.exists)
        XCTAssertTrue(!orSeparator.exists)
        XCTAssertTrue(!secondaryButton.exists)
    }

    func testResendEmail() {
        emailField.tap()
        emailField.typeText("test+resendemail@stytch.com")
        continueButton.tap()

        retryButton.tap()
        app.alerts["Resend link"].scrollViews.otherElements.buttons["Cancel"].tap()

        retryButton.tap()
        app.alerts["Resend link"].scrollViews.otherElements.buttons["Send link"].tap()

        XCTAssertTrue(actionableInfoTitle.exists)
        XCTAssertTrue(actionableInfoLabel.exists)
        XCTAssertTrue(retryButton.exists)
        XCTAssertTrue(!orSeparator.exists)
        XCTAssertTrue(!secondaryButton.exists)
    }
}
