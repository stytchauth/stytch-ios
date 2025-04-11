import Foundation
import XCTest
@testable import StytchCore

// swiftlint:disable type_contents_order

private class NetworkRequestHandlerMock: NetworkRequestHandler {
    private(set) var methodCalled: String?
    var urlSession: URLSession

    required init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    #if os(iOS)
    var captchaProvider: CaptchaProvider {
        ConfiguredRecaptchaProviderMock()
    }

    var dfpProvider: DFPProvider {
        DFPProviderMock()
    }

    func handleDFPDisabled(request _: URLRequest) async throws -> (Data, HTTPURLResponse) {
        methodCalled = "handleDfpDisabled"
        return (Data(), HTTPURLResponse())
    }

    func handleDFPObservationMode(request _: URLRequest, publicToken _: String, dfppaDomain _: String) async throws -> (Data, HTTPURLResponse) {
        methodCalled = "handleDFPObservationMode"
        return (Data(), HTTPURLResponse())
    }

    func handleDFPDecisioningMode(request _: URLRequest, publicToken _: String, dfppaDomain _: String) async throws -> (Data, HTTPURLResponse) {
        methodCalled = "handleDFPDecisioningMode"
        return (Data(), HTTPURLResponse())
    }
    #endif

    func defaultRequestHandler(_: URLRequest) async throws -> (Data, HTTPURLResponse) {
        (Data(), HTTPURLResponse())
    }
}

final class NetworkingClientLiveTestCase: XCTestCase {
    func testDFPDisabled() async throws {
        let handler = NetworkRequestHandlerMock(urlSession: .shared)
        let client = NetworkingClient.live(networkRequestHandler: handler)
        client.dfpEnabled = false
        client.dfpAuthMode = DFPProtectedAuthMode.observation
        _ = try await client.performRequest(.get, url: XCTUnwrap(URL(string: "https://www.stytch.com")), useDFPPA: true)
        #if !os(iOS)
        XCTAssert(handler.methodCalled == nil)
        #else
        XCTAssert(handler.methodCalled == "handleDfpDisabled")
        #endif
    }

    func testDFPObservation() async throws {
        let handler = NetworkRequestHandlerMock(urlSession: .shared)
        let client = NetworkingClient.live(networkRequestHandler: handler)
        client.dfpEnabled = true
        client.dfpAuthMode = DFPProtectedAuthMode.observation
        _ = try await client.performRequest(.get, url: XCTUnwrap(URL(string: "https://www.stytch.com")), useDFPPA: true)
        #if !os(iOS)
        XCTAssert(handler.methodCalled == nil)
        #else
        XCTAssert(handler.methodCalled == "handleDFPObservationMode")
        #endif
    }

    func testDFPDecisioning() async throws {
        let handler = NetworkRequestHandlerMock(urlSession: .shared)
        let client = NetworkingClient.live(networkRequestHandler: handler)
        client.dfpEnabled = true
        client.dfpAuthMode = DFPProtectedAuthMode.decisioning
        _ = try await client.performRequest(.get, url: XCTUnwrap(URL(string: "https://www.stytch.com")), useDFPPA: true)
        #if !os(iOS)
        XCTAssert(handler.methodCalled == nil)
        #else
        XCTAssert(handler.methodCalled == "handleDFPDecisioningMode")
        #endif
    }
}
