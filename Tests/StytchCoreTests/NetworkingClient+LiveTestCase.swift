import Foundation
import XCTest
@testable import StytchCore

private class NetworkRequestHandlerMock: NetworkRequestHandler {
    private(set) var methodCalled: String?
    #if os(iOS)
    func handleDFPDisabled(session _: URLSession, request _: URLRequest, captcha _: CaptchaProvider, requestHandler _: (URLSession, URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse) {
        methodCalled = "handleDfpDisabled"
        return (Data(), HTTPURLResponse())
    }

    // swiftlint:disable:next function_parameter_count
    func handleDFPObservationMode(session _: URLSession, request _: URLRequest, publicToken _: String, dfppaDomain _: String, captcha _: CaptchaProvider, dfp _: DFPProvider, requestHandler _: (URLSession, URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse) {
        methodCalled = "handleDFPObservationMode"
        return (Data(), HTTPURLResponse())
    }

    // swiftlint:disable:next function_parameter_count
    func handleDFPDecisioningMode(session _: URLSession, request _: URLRequest, publicToken _: String, dfppaDomain _: String, captcha _: CaptchaProvider, dfp _: DFPProvider, requestHandler _: (URLSession, URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse) {
        methodCalled = "handleDFPDecisioningMode"
        return (Data(), HTTPURLResponse())
    }
    #endif
}

final class NetworkingClientLiveTestCase: XCTestCase {
    func testDFPDisabled() async throws {
        let handler = NetworkRequestHandlerMock()
        let client = NetworkingClient.live(networkRequestHandler: handler)
        client.dfpEnabled = false
        client.dfpAuthMode = DFPProtectedAuthMode.observation
        try await client.performRequest(.get, url: XCTUnwrap(URL(string: "https://www.stytch.com")))
        #if !os(iOS)
        XCTAssert(handler.methodCalled == nil)
        #else
        XCTAssert(handler.methodCalled == "handleDfpDisabled")
        #endif
    }

    func testDFPObservation() async throws {
        let handler = NetworkRequestHandlerMock()
        let client = NetworkingClient.live(networkRequestHandler: handler)
        client.dfpEnabled = true
        client.dfpAuthMode = DFPProtectedAuthMode.observation
        try await client.performRequest(.get, url: XCTUnwrap(URL(string: "https://www.stytch.com")))
        #if !os(iOS)
        XCTAssert(handler.methodCalled == nil)
        #else
        XCTAssert(handler.methodCalled == "handleDFPObservationMode")
        #endif
    }

    func testDFPDecisioning() async throws {
        let handler = NetworkRequestHandlerMock()
        let client = NetworkingClient.live(networkRequestHandler: handler)
        client.dfpEnabled = true
        client.dfpAuthMode = DFPProtectedAuthMode.decisioning
        try await client.performRequest(.get, url: XCTUnwrap(URL(string: "https://www.stytch.com")))
        #if !os(iOS)
        XCTAssert(handler.methodCalled == nil)
        #else
        XCTAssert(handler.methodCalled == "handleDFPDecisioningMode")
        #endif
    }
}
