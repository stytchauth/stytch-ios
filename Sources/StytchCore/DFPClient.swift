#if os(iOS)
import Foundation
import StytchDFP

internal protocol DFPProvider {
    func getTelemetryId() async -> String
    func configure(publicToken: String, dfppaDomain: String?)
}

final class DFPClient: DFPProvider {
    let stytchDFP = StytchDFP()

    func configure(publicToken: String, dfppaDomain: String?) {
        stytchDFP.configure(withPublicToken: publicToken, submitURL: dfppaDomain)
    }

    @MainActor
    func getTelemetryId() async -> String {
        await withCheckedContinuation { continuation in
            stytchDFP.getTelemetryID { telemetryId in
                continuation.resume(returning: telemetryId)
            }
        }
    }
}
#endif
