#if os(iOS)
import Foundation
import XCTest
@testable import StytchCore

private struct RecaptchaProviderMock: RecaptchaProvider {
    private var didConfigure: Bool = false

    mutating func configure(siteKey _: String) async {
        didConfigure = true
    }

    func getCaptchaToken() async -> String {
        if didConfigure {
            "captcha-token"
        } else {
            ""
        }
    }

    func isConfigured() -> Bool {
        didConfigure
    }
}

// Test that CAPTCHA delegates to the provider
final class CAPTCHATestCase: XCTestCase {
    private let captcha = CAPTCHA(recaptchaProvider: RecaptchaProviderMock())

    func testMethodsWhenNotConfigured() async {
        XCTAssert(captcha.isConfigured() == false)
        let token = await captcha.executeRecaptcha()
        XCTAssert(token.isEmpty)
    }

    func testMethodsWhenConfigured() async {
        XCTAssert(captcha.isConfigured() == false)
        await captcha.setCaptchaClient(siteKey: "my-site-key")
        XCTAssert(captcha.isConfigured() == true)
        let token = await captcha.executeRecaptcha()
        XCTAssert(token == "captcha-token")
    }
}
#endif
