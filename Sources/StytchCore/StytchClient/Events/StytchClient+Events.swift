import Foundation
public protocol EventsProtocol {
    func logEvent(parameters: StytchClient.Events.Parameters) async throws
}

public extension StytchClient {
    struct Events: EventsProtocol {
        let router: NetworkingRouter<EventsRoute>

        @Dependency(\.clientInfo) private var clientInfo
        @Dependency(\.date) private var date
        @Dependency(\.networkingClient) private var networkingClient
        @Dependency(\.uuid) private var uuid
        @Dependency(\.jsonEncoder) private var jsonEncoder

        private let appSessionId: String // Captured value

        init(router: NetworkingRouter<EventsRoute>, appSessionId: String) {
            self.router = router
            self.appSessionId = appSessionId
        }

        public func logEvent(parameters: Parameters) async throws {
            let params = Params(
                telemetry: .init(
                    eventId: "event-id-\(uuid().uuidString)",
                    appSessionId: appSessionId,
                    persistentId: "persistent-id-\(uuid().uuidString)",
                    clientSentAt: date(),
                    timezone: TimeZone.current.identifier,
                    app: clientInfo.app,
                    os: clientInfo.os,
                    sdk: clientInfo.sdk,
                    device: clientInfo.device
                ),
                event: .init(
                    publicToken: networkingClient.publicToken,
                    eventName: parameters.eventName,
                    details: parameters.details
                )
            )
            try await router.post(to: .logEvents, parameters: [params])
        }
    }

    private struct Params: Encodable {
        let telemetry: Telemetry
        let event: Event

        struct Telemetry: Encodable {
            let eventId: String
            let appSessionId: String
            let persistentId: String
            let clientSentAt: Date
            let timezone: String
            let app: ClientInfo.App
            // swiftlint:disable:next identifier_name
            let os: ClientInfo.OperatingSystem
            let sdk: ClientInfo.SDK
            let device: ClientInfo.Device

            public init(
                eventId: String,
                appSessionId: String,
                persistentId: String,
                clientSentAt: Date,
                timezone: String,
                app: ClientInfo.App,
                // swiftlint:disable:next identifier_name
                os: ClientInfo.OperatingSystem,
                sdk: ClientInfo.SDK,
                device: ClientInfo.Device
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
            let details: [String: String]?

            public init(publicToken: String, eventName: String, details: [String: String]? = nil) {
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

public extension StytchClient {
    static var events: Events { .init(router: router.scopedRouter { $0.events }, appSessionId: self.appSessionId) }
}

public extension StytchClient.Events {
    struct Parameters {
        let eventName: String
        let details: [String: String]?

        public init(eventName: String, details: [String: String]? = nil) {
            self.eventName = eventName
            self.details = details
        }
    }
}
