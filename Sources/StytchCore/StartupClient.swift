import Combine
import Foundation

public enum InitializationStatus: Sendable {
    case success
    case failure(errors: [Error])
}

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

    static var isInitialized: AnyPublisher<InitializationStatus, Never> {
        isInitializedPublisher.eraseToAnyPublisher()
    }

    private static let isInitializedPublisher = PassthroughSubject<InitializationStatus, Never>()
    private static var bootstrapError: Error? = nil
    private static var sessionHydrationError: Error? = nil

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
        do {
            _ = try await (auth, bootstrap)
            // We allow the calls to silently fail because they have safe fallbacks, but we want to let the developer know if something went wrong
            let potentialErrors = [bootstrapError, sessionHydrationError].compactMap { $0 }
            if !potentialErrors.isEmpty {
                isInitializedPublisher.send(.failure(errors: potentialErrors))
            } else {
                isInitializedPublisher.send(.success)
            }
        } catch (let error) {
            isInitializedPublisher.send(.failure(errors: [error]))
        }

        StytchConsoleLogger.log(message: "Stytch SDK initialized for client type: \(clientType)")
    }

    private static func authenticateSessionIfNeeded(for clientType: ClientType) async {
        guard Current.sessionManager.hasValidSessionToken else {
            return
        }
        switch clientType {
        case .consumer:
            do {
                _ = try await StytchClient.sessions.authenticate(parameters: .init(sessionDurationMinutes: nil))
                sessionHydrationError = nil
            } catch (let error) {
                sessionHydrationError = error
            }
        case .b2b:
            do {
                _ = try await StytchB2BClient.sessions.authenticate(parameters: .init(sessionDurationMinutes: nil))
                sessionHydrationError = nil
            } catch (let error) {
                sessionHydrationError = error
            }
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
        // Attempt to fetch the latest bootstrap data from the API using the provided public token.
        // If the network request succeeds, extract and use the wrapped response data.
        // If the network request fails, fall back to the locally stored bootstrap data.
        // If no local data exists, use a predefined default bootstrap data.
        do {
            guard let publicToken = StytchClient.stytchClientConfiguration?.publicToken else {
                throw StytchSDKError.consumerSDKNotConfigured
            }
            let updatedBootstrapData = try await router.get(route: .fetch(Path(rawValue: publicToken))) as BootstrapResponse
            bootstrapError = nil
            Current.localStorage.bootstrapData = updatedBootstrapData.wrapped
            return updatedBootstrapData.wrapped
        } catch (let error) {
            bootstrapError = error
            if let currentBootstrapData = Current.localStorage.bootstrapData {
                return currentBootstrapData
            } else {
                Current.localStorage.bootstrapData = BootstrapResponseData.defaultBootstrapData
                return BootstrapResponseData.defaultBootstrapData
            }
        }
    }
}
