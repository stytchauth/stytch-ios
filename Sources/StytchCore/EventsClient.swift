import Foundation

enum EventsClientRoute: BaseRouteType {
    case logEvents

    var path: Path {
        switch self {
        case .logEvents:
            return "events"
        }
    }
}

public enum EventsClient {
    static let router: NetworkingRouter<EventsClientRoute> = .init { Current.localStorage.stytchClientConfiguration }

    static let appSessionId: String = UUID().uuidString

    public static func logEvent(parameters: Parameters) async throws {
        let params = SendParameters(
            telemetry: .init(
                eventId: "event-id-\(Current.uuid().uuidString)",
                appSessionId: appSessionId,
                persistentId: "persistent-id-\(Current.uuid().uuidString)",
                clientSentAt: Current.date(),
                timezone: TimeZone.current.identifier,
                app: Current.clientInfo.app,
                os: Current.clientInfo.os,
                sdk: Current.clientInfo.sdk,
                device: Current.clientInfo.device
            ),
            event: .init(
                publicToken: Current.localStorage.stytchClientConfiguration?.publicToken ?? "",
                eventName: parameters.eventName,
                details: parameters.details,
                error: parameters.error
            )
        )
        try await router.performEventsRequest(to: .logEvents, parameters: [params])
    }
}

public extension EventsClient {
    struct Parameters: Sendable {
        let eventName: String
        let details: [String: String]?
        let error: Error?

        public init(eventName: String, details: [String: String]? = nil, error: Error? = nil) {
            self.eventName = eventName
            self.details = details
            self.error = error
        }
    }
}

extension EventsClient {
    private struct SendParameters: Encodable {
        let telemetry: Telemetry
        let event: Event

        init(telemetry: Telemetry, event: Event) {
            self.telemetry = telemetry
            self.event = event
        }

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

            init(
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

                init(identifier: String, version: String? = nil) {
                    self.identifier = identifier
                    self.version = version
                }
            }

            struct DeviceIdentifier: Encodable {
                let model: String?
                let screenSize: String?

                init(model: String?, screenSize: String? = nil) {
                    self.model = model
                    self.screenSize = screenSize
                }
            }
        }

        struct Event: Encodable {
            let publicToken: String
            let eventName: String
            let details: [String: String]?
            let errorDescription: String?

            init(publicToken: String, eventName: String, details: [String: String]? = nil, error: Error? = nil) {
                self.publicToken = publicToken
                self.eventName = eventName
                self.details = details
                errorDescription = error?.localizedDescription
            }
        }
    }
}
