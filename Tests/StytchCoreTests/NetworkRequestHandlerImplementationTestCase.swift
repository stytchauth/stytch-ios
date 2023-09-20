#if os(iOS)
import Foundation
import XCTest
@testable import StytchCore

private struct RecaptchaProviderMock : RecaptchaProvider {
    private var didConfigure: Bool = false
    mutating func configure(siteKey: String) async {
        didConfigure = siteKey == "set-as-configured"
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

private struct DFPProviderMock : DFPProvider {
    func getTelemetryId(publicToken: String) async -> String {
        "dfp-telemetry-id"
    }
}

private func defaultRequestHandler(session: URLSession, request: URLRequest) async throws -> (Data, HTTPURLResponse) {
    return (Data(), HTTPURLResponse())
}

final class NetworkRequestHandlerImplementationTestCase: XCTestCase {
    let handler = NetworkRequestHandlerImplementation()

    func testHandleDFPDisabled() async throws {
        // if captcha client is configured, add a captcha token, else do nothing
    }

    func testHandleDFPObservationMode() async throws {
        // Always DFP; CAPTCHA if configured
    }

    func testHandleDFPDecisioningMode() async throws {
        // add DFP Id, proceed; if request 403s, add a captcha token
    }
}
#endif
