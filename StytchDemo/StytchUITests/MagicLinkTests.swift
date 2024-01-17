import XCTest

final class MagicLinkTests: XCTestCase {

    private let app = XCUIApplication()
    private lazy var emailField = app.otherElements["emailInput"]
    private lazy var continueButton = app.buttons["continueButton"]
    private lazy var feedbackLabel = app.staticTexts["feedbackLabel"]

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

    func testValidEmail() {
        emailField.tap()
        emailField.typeText("validemail@example.com")

        XCTAssertTrue(continueButton.isEnabled)

        continueButton.tap()
    }
}
