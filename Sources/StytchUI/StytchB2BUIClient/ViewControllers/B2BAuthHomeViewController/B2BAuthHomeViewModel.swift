import Foundation
import StytchCore

protocol B2BAuthHomeViewModelProtocol {
    func logRenderScreen() async throws
}

final class B2BAuthHomeViewModel {
    let state: B2BAuthHomeState

    init(state: B2BAuthHomeState) {
        self.state = state
    }
}

extension B2BAuthHomeViewModel: B2BAuthHomeViewModelProtocol {
    func logRenderScreen() async throws {
        try await EventsClient.logEvent(
            parameters: .init(
                eventName: "render_login_screen",
                details: ["options": String(data: JSONEncoder().encode(state.configuration), encoding: .utf8) ?? ""]
            )
        )
    }
}

struct B2BAuthHomeState {
    let configuration: StytchB2BUIClient.Configuration
}
