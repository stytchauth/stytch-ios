#if os(iOS)
import Foundation
import XCTest
@testable import StytchCore

struct UnconfiguredRecaptchaProviderMock: CaptchaProvider {
    func setCaptchaClient(siteKey _: String) async {}

    func executeRecaptcha() async -> String {
        ""
    }

    func isConfigured() -> Bool {
        false
    }
}

struct ConfiguredRecaptchaProviderMock: CaptchaProvider {
    func setCaptchaClient(siteKey _: String) async {}

    func executeRecaptcha() async -> String {
        "captcha-token"
    }

    func isConfigured() -> Bool {
        true
    }
}

struct DFPProviderMock: DFPProvider {
    func configure(publicToken _: String, dfppaDomain _: String?) {}

    func getTelemetryId() async -> String {
        "dfp-telemetry-id"
    }
}

private extension URLRequest {
    func bodyContainsKey(key: String) throws -> Bool {
        let body: Data = httpBody ?? Data()
        if body.isEmpty {
            return false
        }
        let bodyJSON = try JSONSerialization.jsonObject(with: body) as? [String: AnyObject] ?? [:]
        return bodyJSON[key] != nil
    }
}

// These tests are admittedly a little weird, but basically, I'm just returning either a "good" response or a "bad" response, depending on the test parameters
final class NetworkRequestHandlerTestCase: XCTestCase {
    func testHandleDFPDisabledNoCaptcha() async throws {
        let handler = NetworkRequestHandlerMockLive(urlSession: URLSession(configuration: .default))

        let url = try XCTUnwrap(URL(string: "https://www.stytch.com"))
        _ = try await handler.handleDFPDisabled(request: URLRequest(url: url))

        if let request = handler.request {
            let hasCaptcha = try request.bodyContainsKey(key: "captcha_token")
            let hasDfp = try request.bodyContainsKey(key: "dfp_telemetry_id")
            XCTAssert(!hasDfp)
            XCTAssert(!hasCaptcha)
        } else {
            XCTFail("request should not be nil")
        }
    }

    func testHandleDFPDisabledWithCaptcha() async throws {
        let handler = NetworkRequestHandlerMockLive(urlSession: URLSession(configuration: .default))

        // Must be anything but "GET" to assign captcha to the body
        let url = try XCTUnwrap(URL(string: "https://www.stytch.com"))
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        _ = try await handler.handleDFPDisabled(request: request)

        if let request = handler.request {
            let hasCaptcha = try request.bodyContainsKey(key: "captcha_token")
            let hasDfp = try request.bodyContainsKey(key: "dfp_telemetry_id")
            XCTAssert(!hasDfp)
            XCTAssert(hasCaptcha)
        } else {
            XCTFail("request should not be nil")
        }
    }

    func testHandleDFPObservationModeNoCaptcha() async throws {
        let handler = NetworkRequestHandlerMockLive(urlSession: URLSession(configuration: .default))
        handler.captchaConfigured = false

        let url = try XCTUnwrap(URL(string: "https://www.stytch.com"))
        _ = try await handler.handleDFPObservationMode(request: URLRequest(url: url))

        if let request = handler.request {
            let hasCaptcha = try request.bodyContainsKey(key: "captcha_token")
            let hasDfp = try request.bodyContainsKey(key: "dfp_telemetry_id")
            XCTAssert(hasDfp)
            XCTAssert(!hasCaptcha)
        } else {
            XCTFail("request should not be nil")
        }
    }

    func testHandleDFPObservationModeWithCaptcha() async throws {
        let handler = NetworkRequestHandlerMockLive(urlSession: URLSession(configuration: .default))

        let url = try XCTUnwrap(URL(string: "https://www.stytch.com"))
        _ = try await handler.handleDFPObservationMode(request: URLRequest(url: url))

        if let request = handler.request {
            let hasCaptcha = try request.bodyContainsKey(key: "captcha_token")
            let hasDfp = try request.bodyContainsKey(key: "dfp_telemetry_id")
            XCTAssert(hasDfp)
            XCTAssert(hasCaptcha)
        } else {
            XCTFail("request should not be nil")
        }
    }

    func testHandleDFPDecisioningMode() async throws {
        let handler = NetworkRequestHandlerMockLiveForDFPDecisioningMode(urlSession: URLSession(configuration: .default))

        let url = try XCTUnwrap(URL(string: "https://www.stytch.com"))
        _ = try await handler.handleDFPDecisioningMode(request: URLRequest(url: url))

        if let request1 = handler.request1 {
            let hasCaptcha = try request1.bodyContainsKey(key: "captcha_token")
            let hasDfp = try request1.bodyContainsKey(key: "dfp_telemetry_id")
            // assert that it has dfp and no captcha
            XCTAssert(hasDfp)
            XCTAssert(!hasCaptcha)
        } else {
            XCTFail("request1 should not be nil")
        }

        if let request2 = handler.request2 {
            let hasCaptcha = try request2.bodyContainsKey(key: "captcha_token")
            let hasDfp = try request2.bodyContainsKey(key: "dfp_telemetry_id")
            XCTAssert(hasDfp)
            XCTAssert(hasCaptcha)
        } else {
            XCTFail("request2 should not be nil")
        }
    }
}

class NetworkRequestHandlerMockLive: NetworkRequestHandler {
    var urlSession: URLSession
    var captchaConfigured: Bool = true
    var request: URLRequest?

    var captchaProvider: CaptchaProvider {
        if captchaConfigured {
            ConfiguredRecaptchaProviderMock()
        } else {
            UnconfiguredRecaptchaProviderMock()
        }
    }

    var dfpProvider: DFPProvider {
        DFPProviderMock()
    }

    required init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    func defaultRequestHandler(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        self.request = request
        return (Data(), HTTPURLResponse())
    }
}

// swiftlint:disable type_name
class NetworkRequestHandlerMockLiveForDFPDecisioningMode: NetworkRequestHandler {
    var urlSession: URLSession
    var request1: URLRequest?
    var request2: URLRequest?

    var captchaProvider: CaptchaProvider {
        ConfiguredRecaptchaProviderMock()
    }

    var dfpProvider: DFPProvider {
        DFPProviderMock()
    }

    required init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    func defaultRequestHandler(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        if request1 == nil, request2 == nil {
            request1 = request
            // force return a 403
            // swiftlint:disable:next force_unwrapping
            return (Data(), HTTPURLResponse(url: request1!.url!, statusCode: 403, httpVersion: "1.1", headerFields: nil)!)
        } else if request1 != nil {
            request2 = request
            return (Data(), HTTPURLResponse())
        } else {
            return (Data(), HTTPURLResponse())
        }
    }
}

#endif
