extension StytchClient {
    struct Events {
        let router: NetworkingRouter<EventsRoute>

        public func logEvent(parameters: Parameters) async throws -> NoResponse {
            try await router.post(to: .logEvents, parameters: [parameters])
        }
    }
}

internal extension StytchClient {
    static var events: Events { .init(router: router.scopedRouter { $0.events }) }
}

extension StytchClient.Events {
    struct Parameters: Encodable {
        let telemetry: Telemetry
        let event: Event

        struct Telemetry: Encodable {
            let eventId: String
            let appSessionId: String
            let persistentId: String
            let clientSentAt: String
            let timezone: String
            let app: VersionIdentifier
            let os: VersionIdentifier
            let sdk: VersionIdentifier
            let device: DeviceIdentifier

            public init(
                eventId: String,
                appSessionId: String,
                persistentId: String,
                clientSentAt: String, 
                timezone: String,
                app: VersionIdentifier,
                os: VersionIdentifier,
                sdk: VersionIdentifier,
                device: DeviceIdentifier
            ) {
                self.eventId = eventId
                self.appSessionId = appSessionId
                self.persistentId = persistentId
                self.clientSentAt = clientSentAt
                self.timezone = timezone
                self.app = app
                self.os = os
                self.sdk = sdk
                self.device = device
            }

            struct VersionIdentifier: Encodable {
                let identifier: String
                let version: String?

                public init(identifier: String, version: String? = nil) {
                    self.identifier = identifier
                    self.version = version
                }
            }

            struct DeviceIdentifier: Encodable {
                let model: String?
                let screenSize: String?

                public init(model: String?, screenSize: String? = nil) {
                    self.model = model
                    self.screenSize = screenSize
                }
            }
        }

        struct Event: Encodable {
            let publicToken: String
            let eventName: String
            let details: Dictionary<String, String>?

            public init(publicToken: String, eventName: String, details: Dictionary<String, String>? = nil) {
                self.publicToken = publicToken
                self.eventName = eventName
                self.details = details
            }
        }

        public init(telemetry: Telemetry, event: Event) {
            self.telemetry = telemetry
            self.event = event
        }
    }
}

extension StytchClient.Events {
    typealias NoResponse = Response<NoResponseData>

    struct NoResponseData: Codable {}
}
