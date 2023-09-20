import Foundation
import XCTest
@testable import StytchCore

private struct DFPProviderMock: DFPProvider {
    func getTelemetryId(publicToken: String) async -> String {
        if publicToken == "bad" {
            return ""
        } else {
            return "dfp-telemetry-id"
        }
    }
}

// Test that DFPClient delegates to the provider
final class DFPClientTestCase: XCTestCase {
    private let dfpClient = DFPClient(dfpProvider: DFPProviderMock())

    func testDfpClient() async {
        var telemetryId = await dfpClient.getTelemetryId(publicToken: "bad")
        XCTAssert(telemetryId.isEmpty)
        telemetryId = await dfpClient.getTelemetryId(publicToken: "public-token-test-123")
        XCTAssert(telemetryId == "dfp-telemetry-id")
    }
}
