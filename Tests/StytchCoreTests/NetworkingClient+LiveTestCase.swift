import Foundation
import XCTest
@testable import StytchCore

private class NetworkRequestHandlerMock: NetworkRequestHandler {
    private(set) var methodCalled: String? = nil
    #if os(iOS)
    func handleDFPDisabled(session: URLSession, request: URLRequest, captcha: CAPTCHA, requestHandler: (URLSession, URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse) {
        methodCalled = "handleDfpDisabled"
        return (Data(), HTTPURLResponse())
    }

    func handleDFPObservationMode(session: URLSession, request: URLRequest, publicToken: String, captcha: CAPTCHA, dfp: DFPClient, requestHandler: (URLSession, URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse) {
        methodCalled = "handleDFPObservationMode"
        return (Data(), HTTPURLResponse())
    }

    func handleDFPDecisioningMode(session: URLSession, request: URLRequest, publicToken: String, captcha: CAPTCHA, dfp: DFPClient, requestHandler: (URLSession, URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse) {
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
        let _ = try await client.performRequest(.get, url: XCTUnwrap(URL(string: "https://www.stytch.com")))
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
        let _ = try await client.performRequest(.get, url: XCTUnwrap(URL(string: "https://www.stytch.com")))
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
        let _ = try await client.performRequest(.get, url: XCTUnwrap(URL(string: "https://www.stytch.com")))
        #if !os(iOS)
        XCTAssert(handler.methodCalled == nil)
        #else
        XCTAssert(handler.methodCalled == "handleDFPDecisioningMode")
        #endif
    }
}
