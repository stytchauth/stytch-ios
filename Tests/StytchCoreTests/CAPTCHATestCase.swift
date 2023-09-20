import Foundation
import XCTest
@testable import StytchCore

#if os(iOS)
struct RecaptchaProviderSpy : RecaptchaProvider {
    private var didConfigure: Bool = false

    mutating func configure(siteKey: String) async {
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
    let captcha = CAPTCHA(recaptchaProvider: RecaptchaProviderSpy())

    func testMethodsWhenNotConfigured() async {
        XCTAssert(captcha.isConfigured() == false)
        let token = await captcha.executeRecaptcha()
        XCTAssert(token == "")
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
