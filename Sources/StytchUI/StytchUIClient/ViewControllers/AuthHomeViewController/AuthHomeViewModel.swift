import Foundation
import StytchCore

protocol AuthHomeViewModelProtocol {
    func logRenderScreen() async throws
    func checkValidConfig() throws
}

final class AuthHomeViewModel {
    let state: AuthHomeState

    init(state: AuthHomeState) {
        self.state = state
    }
}

extension AuthHomeViewModel: AuthHomeViewModelProtocol {
    func logRenderScreen() async throws {
        try await EventsClient.logEvent(
            parameters: .init(
                eventName: "render_login_screen",
                details: ["options": String(data: JSONEncoder().encode(state.config), encoding: .utf8) ?? ""]
            )
        )
    }

    func checkValidConfig() throws {
        if state.config.supportsEmailMagicLinks, let otp = state.config.otpOptions, otp.methods.contains(.email) {
            throw StytchSDKError.uiEmlAndOtpInvalid
        }
    }
}

struct AuthHomeState {
    let config: StytchUIClient.Configuration
}
