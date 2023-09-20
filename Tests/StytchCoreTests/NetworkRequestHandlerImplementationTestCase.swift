#if os(iOS)
import Foundation
import XCTest
@testable import StytchCore

private struct UnconfiguredRecaptchaProviderMock : RecaptchaProvider {
    mutating func configure(siteKey: String) async {
    }

    func getCaptchaToken() async -> String {
        ""
    }

    func isConfigured() -> Bool {
        false
    }
}

private struct ConfiguredRecaptchaProviderMock : RecaptchaProvider {
    mutating func configure(siteKey: String) async {
    }

    func getCaptchaToken() async -> String {
        "captcha-token"
    }

    func isConfigured() -> Bool {
        true
    }
}

private struct DFPProviderMock : DFPProvider {
    func getTelemetryId(publicToken: String) async -> String {
        "dfp-telemetry-id"
    }
}

private func defaultRequestHandler(session: URLSession, request: URLRequest) async throws -> (Data, HTTPURLResponse) {
    return (Data(), HTTPURLResponse())
}

private extension URLRequest {
    func bodyContainsKey(key: String) throws -> Bool {
        let body: Data = self.httpBody ?? Data()
        if body.isEmpty {
            return false
        }
        let bodyJSON = try JSONSerialization.jsonObject(with: body) as? [String: AnyObject] ?? [:]
        return bodyJSON[key] != nil
    }
}

// These tests are admittedly a little weird, but basically, I'm just returning either a "good" response or a "bad" response, depending on the test parameters
final class NetworkRequestHandlerImplementationTestCase: XCTestCase {
    let handler = NetworkRequestHandlerImplementation()
    let dfpClient = DFPClient(dfpProvider: DFPProviderMock())

    func testHandleDFPDisabledNoCaptcha() async throws {
        // do nothing to the request
        let captcha = CAPTCHA(recaptchaProvider: UnconfiguredRecaptchaProviderMock())
        let url = try XCTUnwrap(URL(string: "https://www.stytch.com"))

        func requestHandler(session: URLSession, request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            let hasCaptcha = try request.bodyContainsKey(key: "captcha_token")
            let hasDfp = try request.bodyContainsKey(key: "dfp_telemetry_id")
            XCTAssert(!hasDfp)
            XCTAssert(!hasCaptcha)
            return (Data(), HTTPURLResponse())
        }
        let (_, _) = try await handler.handleDFPDisabled(session: URLSession(), request: URLRequest(url:url), captcha: captcha, requestHandler: requestHandler)
    }

    func testHandleDFPDisabledWithCaptcha() async throws {
        // add a captcha token to the request
        let captcha = CAPTCHA(recaptchaProvider: ConfiguredRecaptchaProviderMock())
        let url = try XCTUnwrap(URL(string: "https://www.stytch.com"))

        func requestHandler(session: URLSession, request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            let hasCaptcha = try request.bodyContainsKey(key: "captcha_token")
            let hasDfp = try request.bodyContainsKey(key: "dfp_telemetry_id")
            XCTAssert(!hasDfp)
            XCTAssert(hasCaptcha)
            return (Data(), HTTPURLResponse())
        }
        let (_, response) = try await handler.handleDFPDisabled(session: URLSession(), request: URLRequest(url:url), captcha: captcha, requestHandler: requestHandler)
    }

    func testHandleDFPObservationModeNoCaptcha() async throws {
        // add DFP, no captcha token
        let captcha = CAPTCHA(recaptchaProvider: UnconfiguredRecaptchaProviderMock())
        let url = try XCTUnwrap(URL(string: "https://www.stytch.com"))

        func requestHandler(session: URLSession, request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            let hasCaptcha = try request.bodyContainsKey(key: "captcha_token")
            let hasDfp = try request.bodyContainsKey(key: "dfp_telemetry_id")
            XCTAssert(hasDfp)
            XCTAssert(!hasCaptcha)
            return (Data(), HTTPURLResponse())
        }
        let (_, _) = try await handler.handleDFPObservationMode(session: URLSession(), request: URLRequest(url:url), publicToken: "", captcha: captcha, dfp: dfpClient, requestHandler: requestHandler)
    }

    func testHandleDFPObservationModeWithCaptcha() async throws {
        // add dfp and captcha token
        let captcha = CAPTCHA(recaptchaProvider: ConfiguredRecaptchaProviderMock())
        let url = try XCTUnwrap(URL(string: "https://www.stytch.com"))

        func requestHandler(session: URLSession, request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            let hasCaptcha = try request.bodyContainsKey(key: "captcha_token")
            let hasDfp = try request.bodyContainsKey(key: "dfp_telemetry_id")
            XCTAssert(hasDfp)
            XCTAssert(hasCaptcha)
            return (Data(), HTTPURLResponse())
        }
        let (_, _) = try await handler.handleDFPObservationMode(session: URLSession(), request: URLRequest(url:url), publicToken: "", captcha: captcha, dfp: dfpClient, requestHandler: requestHandler)
    }

    func testHandleDFPDecisioningMode() async throws {
        // add DFP Id, proceed; if request 403s, add a captcha token
        let captcha = CAPTCHA(recaptchaProvider: ConfiguredRecaptchaProviderMock())
        let url = try XCTUnwrap(URL(string: "https://www.stytch.com"))
        var requestNumber = 0

        func requestHandler(session: URLSession, request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            requestNumber += 1
            let hasCaptcha = try request.bodyContainsKey(key: "captcha_token")
            let hasDfp = try request.bodyContainsKey(key: "dfp_telemetry_id")
            if (requestNumber == 1) {
                //assert that it has dfp and no captcha
                XCTAssert(hasDfp)
                XCTAssert(!hasCaptcha)
                // force return a 403
                return (Data(), HTTPURLResponse(url: url, statusCode: 403, httpVersion: "1.1", headerFields: nil)!)
            } else {
                XCTAssert(hasDfp)
                XCTAssert(hasCaptcha)
                return (Data(), HTTPURLResponse())
            }
        }
        let (_, _) = try await handler.handleDFPDecisioningMode(session: URLSession(), request: URLRequest(url:url), publicToken: "", captcha: captcha, dfp: dfpClient, requestHandler: requestHandler)
    }
}
#endif
