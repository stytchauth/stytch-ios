import Foundation
import StytchCore

protocol AuthHomeViewModelProtocol {
    func logRenderScreen() async throws
}

final class AuthHomeViewModel {
    let state: AuthHomeState
    let eventsClient: StytchClientEventsProtocol

    init(
        state: AuthHomeState,
        eventsClient: StytchClientEventsProtocol = StytchClient.events
    ) {
        self.state = state
        self.eventsClient = eventsClient
    }
}

extension AuthHomeViewModel: AuthHomeViewModelProtocol {
    func logRenderScreen() async throws {
        try await eventsClient.logEvent(
            parameters: .init(
                eventName: "render_login_screen",
                details: ["options": String(data: JSONEncoder().encode(state.config), encoding: .utf8) ?? ""]
            )
        )
    }
}

struct AuthHomeState {
    let bootstrap: Bootstrap
    let config: StytchUIClient.Configuration
}
