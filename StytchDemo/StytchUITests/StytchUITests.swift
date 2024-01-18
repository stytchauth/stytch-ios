import XCTest

final class StytchUITests: XCTestCase {

    let app = XCUIApplication()

    lazy var titleLabel = app.scrollViews.otherElements.staticTexts["Sign up or log in"]
    lazy var separatorView = app.scrollViews.otherElements.staticTexts["or"]
    lazy var poweredByStytch = app.images.element(matching: .any, identifier: "poweredByStytch")

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    func testDefaultUIRendersAsExpected() throws {
        app.launchEnvironment["config"] = "default"
        app.launch()

        XCTAssert(titleLabel.exists)
        XCTAssert(!separatorView.exists)
    }

    func testRealisticUIRendersAsExpected() throws {
        app.launchEnvironment["config"] = "realistic"
        app.launch()

        XCTAssert(titleLabel.exists)
        XCTAssert(separatorView.exists)
        XCTAssert(poweredByStytch.exists)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
