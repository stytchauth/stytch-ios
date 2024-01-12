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

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
