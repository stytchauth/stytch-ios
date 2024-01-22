import StytchCore

protocol AuthHomeViewModelProtocol {
    func logEvent(name: String) async throws
}

final class AuthHomeViewModel {
    let state: AuthHomeState
    let eventsClient: EventsProtocol

    init(
        state: AuthHomeState,
        eventsClient: EventsProtocol = StytchClient.events
    ) {
        self.state = state
        self.eventsClient = eventsClient
    }
}

extension AuthHomeViewModel: AuthHomeViewModelProtocol {
    func logEvent(
        name: String
    ) async throws {
        try await eventsClient.logEvent(
            parameters: .init(
                eventName: name
            )
        )
    }
}

struct AuthHomeState {
    let bootstrap: Bootstrap
    let config: StytchUIClient.Configuration
}
