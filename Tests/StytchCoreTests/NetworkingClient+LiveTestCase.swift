import Foundation
import XCTest
@testable import StytchCore

private class NetworkRequestHandlerMock: NetworkRequestHandler {
    private(set) var methodCalled: String? = nil

    func makeRequest(session: URLSession, request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        methodCalled = "makeRequest"
        return (Data(), HTTPURLResponse())
    }
    #if os(iOS)
    func handleDFPDisabled(session: URLSession, request: URLRequest, captcha: CAPTCHA) async throws -> (Data, HTTPURLResponse) {
        methodCalled = "handleDfpDisabled"
        return (Data(), HTTPURLResponse())
    }

    func handleDFPObservationMode(session: URLSession, request: URLRequest, publicToken: String, captcha: CAPTCHA, dfp: DFPClient) async throws -> (Data, HTTPURLResponse) {
        methodCalled = "handleDFPObservationMode"
        return (Data(), HTTPURLResponse())
    }

    func handleDFPDecisioningMode(session: URLSession, request: URLRequest, publicToken: String, captcha: CAPTCHA, dfp: DFPClient) async throws -> (Data, HTTPURLResponse) {
        methodCalled = "handleDFPDecisioningMode"
        return (Data(), HTTPURLResponse())
    }
    #endif
}

final class NetworkingClientLiveTestCase: XCTestCase {
    private let handler = NetworkRequestHandlerMock()

    func testCallsAppropriateMethodInNetworkRequestHandler() async throws {
        let client = NetworkingClient.live(networkRequestHandler: handler)

        // DFP DISABLED
        client.dfpEnabled = false
        client.dfpAuthMode = DFPProtectedAuthMode.observation
        let _ = try await client.performRequest(.get, url: XCTUnwrap(URL(string: "https://www.stytch.com")))
        #if !os(iOS)
        XCTAssert(handler.methodCalled == "makeRequest")
        #else
        XCTAssert(handler.methodCalled == "handleDfpDisabled")
        #endif

        // DFP ENABLED + OBSERVATION MODE
        client.dfpEnabled = true
        client.dfpAuthMode = DFPProtectedAuthMode.observation
        let _ = try await client.performRequest(.get, url: XCTUnwrap(URL(string: "https://www.stytch.com")))
        #if !os(iOS)
        XCTAssert(handler.methodCalled == "makeRequest")
        #else
        XCTAssert(handler.methodCalled == "handleDFPObservationMode")
        #endif

        // DFP ENABLED + DECISIONING MODE
        client.dfpEnabled = true
        client.dfpAuthMode = DFPProtectedAuthMode.decisioning
        let _ = try await client.performRequest(.get, url: XCTUnwrap(URL(string: "https://www.stytch.com")))
        #if !os(iOS)
        XCTAssert(handler.methodCalled == "makeRequest")
        #else
        XCTAssert(handler.methodCalled == "handleDFPDecisioningMode")
        #endif
    }
}
