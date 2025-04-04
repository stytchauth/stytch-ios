import Combine
import Foundation

public protocol RouteType {
    var path: Path { get }
}

protocol BaseRouteType: RouteType {}

public struct NetworkingRouter<Route: RouteType> {
    private let getConfiguration: () -> StytchClientConfiguration?

    private let pathForRoute: (Route) -> Path

    @Dependency(\.jsonEncoder) private var jsonEncoder

    @Dependency(\.jsonDecoder) private var jsonDecoder

    @Dependency(\.networkingClient) private var networkingClient

    @Dependency(\.sessionManager) private var sessionManager

    @Dependency(\.userStorage) private var userStorage

    @Dependency(\.memberStorage) private var memberStorage

    @Dependency(\.organizationStorage) private var organizationStorage

    @Dependency(\.localStorage) private var localStorage

    @Dependency(\.keychainClient) private var keychainClient

    private init(_ pathForRoute: @escaping (Route) -> Path, getConfiguration: @escaping () -> StytchClientConfiguration?) {
        self.getConfiguration = getConfiguration
        self.pathForRoute = pathForRoute
    }

    func scopedRouter<ScopedRoute: RouteType>(
        _ transformToRoute: @escaping (Route.Type) -> (ScopedRoute) -> Route
    ) -> NetworkingRouter<ScopedRoute> {
        .init { path(for: transformToRoute(Route.self)($0)) } getConfiguration: { getConfiguration() }
    }

    private func path(for route: Route) -> Path {
        pathForRoute(route)
    }
}

public extension NetworkingRouter {
    func post<Parameters: Encodable>(
        to route: Route,
        parameters: Parameters,
        useDFPPA: Bool = false
    ) async throws {
        try await performRequest(.post(jsonEncoder.encode(parameters)), route: route, useDFPPA: useDFPPA)
    }

    func post<Response: Decodable>(
        to route: Route,
        useDFPPA: Bool = false
    ) async throws -> Response {
        try await performRequest(.post(nil), route: route, useDFPPA: useDFPPA)
    }

    func post<Parameters: Encodable, Response: Decodable>(
        to route: Route,
        parameters: Parameters,
        useDFPPA: Bool = false
    ) async throws -> Response {
        try await performRequest(.post(jsonEncoder.encode(parameters)), route: route, useDFPPA: useDFPPA)
    }

    func put<Parameters: Encodable, Response: Decodable>(
        to route: Route,
        parameters: Parameters,
        useDFPPA: Bool = false
    ) async throws -> Response {
        try await performRequest(.put(jsonEncoder.encode(parameters)), route: route, useDFPPA: useDFPPA)
    }

    func get<Response: Decodable>(
        route: Route,
        useDFPPA: Bool = false
    ) async throws -> Response {
        try await performRequest(.get, route: route, useDFPPA: useDFPPA)
    }

    func delete<Response: Decodable>(
        route: Route,
        useDFPPA: Bool = false
    ) async throws -> Response {
        try await performRequest(.delete, route: route, useDFPPA: useDFPPA)
    }
}

public extension NetworkingRouter {
    private func performRequest(
        _ method: NetworkingClient.Method,
        route: Route,
        useDFPPA: Bool
    ) async throws {
        guard let configuration = getConfiguration() else {
            throw StytchSDKError.consumerSDKNotConfigured
        }

        let (data, response) = try await networkingClient.performRequest(
            method,
            url: configuration.baseUrl.appendingPathComponent(path(for: route).rawValue),
            useDFPPA: useDFPPA
        )

        do {
            try response.verifyStatusCode(data: data, jsonDecoder: jsonDecoder)
        } catch let error as StytchAPIError where error.statusCode == 401 {
            sessionManager.resetSession()
            throw error
        } catch {
            throw error
        }
    }

    private func performRequest<Response: Decodable>(
        _ method: NetworkingClient.Method,
        route: Route,
        useDFPPA: Bool
    ) async throws -> Response {
        guard let configuration = getConfiguration() else {
            throw StytchSDKError.consumerSDKNotConfigured
        }
        let url = configuration.baseUrl.appendingPathComponent(path(for: route).rawValue)
        let (data, response) = try await networkingClient.performRequest(method, url: url, useDFPPA: useDFPPA)

        do {
            try response.verifyStatusCode(data: data, jsonDecoder: jsonDecoder)
            let dataContainer = try jsonDecoder.decode(DataContainer<Response>.self, from: data)
            if let sessionResponse = dataContainer.data as? AuthenticateResponseType {
                sessionManager.updateSession(
                    sessionType: .user(sessionResponse.session),
                    tokens: SessionTokens(jwt: .jwt(sessionResponse.sessionJwt), opaque: .opaque(sessionResponse.sessionToken)),
                    hostUrl: configuration.hostUrl
                )
                userStorage.update(sessionResponse.user)
                #if !os(tvOS) && !os(watchOS)
                StytchClient.biometrics.cleanupPotentiallyOrphanedBiometricRegistrations()
                #endif
            } else if let sessionResponse = dataContainer.data as? B2BAuthenticateResponseType {
                sessionManager.updateSession(
                    sessionType: .member(sessionResponse.memberSession),
                    tokens: SessionTokens(jwt: .jwt(sessionResponse.sessionJwt), opaque: .opaque(sessionResponse.sessionToken)),
                    hostUrl: configuration.hostUrl
                )
                memberStorage.update(sessionResponse.member)
                organizationStorage.update(sessionResponse.organization)
            } else if let sessionResponse = dataContainer.data as? B2BMFAAuthenticateResponseType {
                if let memberSession = sessionResponse.memberSession {
                    sessionManager.updateSession(
                        sessionType: .member(memberSession),
                        tokens: SessionTokens(jwt: .jwt(sessionResponse.sessionJwt), opaque: .opaque(sessionResponse.sessionToken)),
                        hostUrl: configuration.hostUrl
                    )
                } else {
                    sessionManager.updateSession(
                        intermediateSessionToken: sessionResponse.intermediateSessionToken
                    )
                }
                memberStorage.update(sessionResponse.member)
                organizationStorage.update(sessionResponse.organization)
            } else if let sessionResponse = dataContainer.data as? DiscoveryIntermediateSessionTokenDataType {
                sessionManager.updateSession(
                    intermediateSessionToken: sessionResponse.intermediateSessionToken
                )
            }
            return dataContainer.data
        } catch {
            throw error
        }
    }
}

extension NetworkingRouter where Route: BaseRouteType {
    init(getConfiguration: @escaping () -> StytchClientConfiguration?) {
        self.init { $0.path } getConfiguration: { getConfiguration() }
    }
}

private extension HTTPURLResponse {
    func verifyStatusCode(data: Data, jsonDecoder: JSONDecoder) throws {
        let isErrorCode = (400..<600).contains(statusCode)
        guard isErrorCode == true else {
            return
        }

        let error: Error
        do {
            // Attempt to parse as a StytchAPIError
            error = try jsonDecoder.decode(StytchAPIError.self, from: data)
        } catch _ {
            // If parsing fails create a StytchAPIError with an unknown error type and use the raw JSON string as the message if possible.
            let debugInfo = String(data: data, encoding: .utf8) ?? "none"
            error = StytchAPIError(unknownErrorWithStatusCode: statusCode, debugInfo: debugInfo)
        }

        throw error
    }
}
