import Combine
import Foundation

struct StartupClient {
    enum BootstrapRoute: BaseRouteType {
        case fetch(Path)

        var path: Path {
            switch self {
            case let .fetch(publicToken):
                return "projects/bootstrap".appendingPath(publicToken)
            }
        }
    }

    static let router: NetworkingRouter<BootstrapRoute> = .init { Current.localStorage.configuration }
    static var clientType: ClientType?

    static var isInitialized: AnyPublisher<Bool, Never> {
        isInitializedPublisher.eraseToAnyPublisher()
    }

    private static let isInitializedPublisher = PassthroughSubject<Bool, Never>()

    static func start() async throws {
        if let clientType {
            try await start(type: clientType)
        } else {
            throw StytchSDKError.startupClientNotConfiguredForClientType
        }
    }

    static func start(type: ClientType) async throws {
        clientType = type

        let bootstrapResponseData = try await bootstrap()

        #if os(iOS)
        Current.networkingClient.dfpEnabled = bootstrapResponseData.dfpProtectedAuthEnabled
        Current.networkingClient.dfpAuthMode = bootstrapResponseData.dfpProtectedAuthMode ?? DFPProtectedAuthMode.observation
        if let siteKey = bootstrapResponseData.captchaSettings.siteKey, siteKey.isEmpty == false {
            await Current.captcha.setCaptchaClient(siteKey: siteKey)
        }
        #endif

        if Current.sessionManager.persistedSessionIdentifiersExist {
            if clientType == .consumer {
                _ = try? await StytchClient.sessions.authenticate(parameters: .init(sessionDurationMinutes: nil))
            } else if clientType == .b2b {
                _ = try? await StytchB2BClient.sessions.authenticate(parameters: .init(sessionDurationMinutes: nil))
            }
        }

        isInitializedPublisher.send(true)
    }

    @discardableResult static func bootstrap() async throws -> BootstrapResponseData {
        guard let publicToken = StytchClient.instance.configuration?.publicToken else {
            throw StytchSDKError.consumerSDKNotConfigured
        }

        // Attempt to fetch the latest bootstrap data from the API using the provided public token.
        // If the network request succeeds, extract and use the wrapped response data.
        // If the network request fails, fall back to the locally stored bootstrap data.
        // If no local data exists, use a predefined default bootstrap data.
        let bootstrapResponseData: BootstrapResponseData
        if let bootstrapData = try? await router.get(route: .fetch(Path(rawValue: publicToken))) as BootstrapResponse {
            bootstrapResponseData = bootstrapData.wrapped
        } else if let currentBootstrapData = Current.localStorage.bootstrapData {
            bootstrapResponseData = currentBootstrapData
        } else {
            bootstrapResponseData = BootstrapResponseData.defaultBootstrapData
        }

        // Update the local storage with the resolved bootstrap data before returning it.
        Current.localStorage.bootstrapData = bootstrapResponseData

        return bootstrapResponseData
    }
}
