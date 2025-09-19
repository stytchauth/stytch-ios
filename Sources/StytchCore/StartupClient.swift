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

    static let router: NetworkingRouter<BootstrapRoute> = .init {
        Current.localStorage.stytchClientConfiguration
    }

    static var expectedClientType: ClientType?

    static var isInitialized: AnyPublisher<Bool, Never> {
        isInitializedPublisher.eraseToAnyPublisher()
    }

    private static let isInitializedPublisher = PassthroughSubject<Bool, Never>()

    static func start() async throws {
        if let expectedClientType {
            try await start(clientType: expectedClientType)
        } else {
            throw StytchSDKError.startupClientNotConfiguredForClientType
        }
    }

    static func start(clientType: ClientType) async throws {
        expectedClientType = clientType

        async let auth: () = authenticateSessionIfNeeded(for: clientType)
        async let bootstrap: () = fetchAndApplyBootstrap()

        // Await both tasks to complete
        _ = try await (auth, bootstrap)

        isInitializedPublisher.send(true)

        StytchConsoleLogger.log(message: "Stytch SDK initialized for client type: \(clientType)")
    }

    private static func authenticateSessionIfNeeded(for clientType: ClientType) async {
        guard Current.sessionManager.hasValidSessionToken else {
            return
        }
        switch clientType {
        case .consumer:
            _ = try? await StytchClient.sessions.authenticate(parameters: .init(sessionDurationMinutes: nil))
        case .b2b:
            _ = try? await StytchB2BClient.sessions.authenticate(parameters: .init(sessionDurationMinutes: nil))
        }
    }

    private static func fetchAndApplyBootstrap() async throws {
        let bootstrapData = try await bootstrap()

        if expectedClientType == .consumer, bootstrapData.clientType == .b2b {
            print("This application is using a Stytch client for Consumer projects, but the public token is for a Stytch B2B project. Use a B2B Stytch client instead, or verify that the public token is correct.")
        }

        if expectedClientType == .b2b, bootstrapData.clientType == .consumer {
            print("This application is using a Stytch client for B2B projects, but the public token is for a Stytch Consumer project. Use a Consumer Stytch client instead, or verify that the public token is correct.")
        }

        #if canImport(StytchDFP)
        Current.networkingClient.configureDFP(
            dfpEnabled: bootstrapData.dfpProtectedAuthEnabled,
            dfpAuthMode: bootstrapData.dfpProtectedAuthMode
        )

        if let siteKey = bootstrapData.captchaSettings.siteKey, !siteKey.isEmpty {
            await Current.captcha.setCaptchaClient(siteKey: siteKey)
        }
        #endif
    }

    @discardableResult static func bootstrap() async throws -> BootstrapResponseData {
        guard let publicToken = StytchClient.stytchClientConfiguration?.publicToken else {
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
