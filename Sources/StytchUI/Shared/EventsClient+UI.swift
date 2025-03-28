import StytchCore

extension EventsClient {
    static func sendAuthenticationSuccessEvent() {
        Task {
            try? await EventsClient.logEvent(parameters: .init(eventName: "ui_authentication_success"))
        }
    }
}
