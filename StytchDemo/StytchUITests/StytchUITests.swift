import XCTest

final class StytchUITests: XCTestCase {

    let app = XCUIApplication()

    lazy var titleLabel = app.staticTexts.element(matching: .any, identifier: "authTitle")
    lazy var separatorView = app.otherElements.element(matching: .any, identifier: "orSeparator")
    lazy var poweredByStytch = app.images.element(matching: .any, identifier: "poweredByStytch")

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app.terminate()
    }

    func testDefaultUIRendersAsExpected() throws {
        // UI tests must launch the application that they test.
        app.launchEnvironment["config"] = "default"
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssert(titleLabel.exists)
        XCTAssert(!separatorView.exists)
        XCTAssert(poweredByStytch.exists)
    }

    func testRealisticUIRendersAsExpected() throws {
        // UI tests must launch the application that they test.
        app.launchEnvironment["config"] = "realistic"
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssert(titleLabel.exists)
        XCTAssert(separatorView.exists)
        XCTAssert(poweredByStytch.exists)
    }

    func testOTPScreen() throws {
        // UI tests must launch the application that they test.
        app.launchEnvironment["config"] = "realistic"
        app.launch()
        let phoneNumberInput = app.otherElements.element(matching: .any, identifier: "phoneNumberEntry")

        // Default
        XCTAssert(!phoneNumberInput.exists)

        // Switch to phone input and enter number
        app.otherElements/*@START_MENU_TOKEN@*/.buttons["Text"]/*[[".segmentedControls[\"emailTextSegmentedControl\"].buttons[\"Text\"]",".buttons[\"Text\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        XCTAssert(phoneNumberInput.exists)
        let phoneInput = phoneNumberInput.descendants(matching: .textField).element
        phoneInput.tap()
        phoneInput.typeText("5005550006")
        app.otherElements.buttons["continueButton"].tap()
        // Wait to navigate to OTP screen
        let otpPageTitle = app.staticTexts.element(matching: .any, identifier: "otpConfirmationTitle")
        let otpPhoneLabel = app.staticTexts.element(matching: .any, identifier: "phoneLabel")
        let otpEntry = app.textFields.element(matching: .any, identifier: "otpEntry")
        let expiryButton = app.buttons.element(matching: .any, identifier: "expiryButton")
        let _ = otpPageTitle.waitForExistence(timeout: 10)
        XCTAssert(otpPageTitle.exists)
        XCTAssert(otpPhoneLabel.exists)
        XCTAssert(otpEntry.exists)
        XCTAssert(expiryButton.exists)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

