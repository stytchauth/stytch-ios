import Combine
import Foundation

public protocol RouteType {
    var path: Path { get }
}

public struct NetworkingRouter<Route: RouteType> {
    private let getConfiguration: () -> Configuration?

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

    private init(_ pathForRoute: @escaping (Route) -> Path, getConfiguration: @escaping () -> Configuration?) {
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
            try response.verifyStatus(data: data, jsonDecoder: jsonDecoder)
        } catch let error as StytchAPIError where error.statusCode == 401 {
            sessionManager.resetSession()
            throw error
        } catch {
            throw error
        }
    }

    // swiftlint:disable:next function_body_length
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
            try response.verifyStatus(data: data, jsonDecoder: jsonDecoder)
            let dataContainer = try jsonDecoder.decode(DataContainer<Response>.self, from: data)
            if let sessionResponse = dataContainer.data as? AuthenticateResponseType {
                sessionManager.updateSession(
                    sessionType: .user(sessionResponse.session),
                    tokens: SessionTokens(jwt: .jwt(sessionResponse.sessionJwt), opaque: .opaque(sessionResponse.sessionToken)),
                    hostUrl: configuration.hostUrl
                )
                userStorage.update(sessionResponse.user)
                StytchClient.biometrics.cleanupPotentiallyOrphanedBiometricRegistrations()
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
        } catch let error as StytchAPIError where error.statusCode == 401 {
            sessionManager.resetSession()
            throw error
        } catch {
            throw error
        }
    }
}

protocol BaseRouteType: RouteType {}

extension NetworkingRouter where Route: BaseRouteType {
    init(getConfiguration: @escaping () -> Configuration?) {
        self.init { $0.path } getConfiguration: { getConfiguration() }
    }
}

private extension HTTPURLResponse {
    func verifyStatus(data: Data, jsonDecoder: JSONDecoder) throws {
        guard (400..<600).contains(statusCode) else { return }

        let error: Error

        do {
            error = try jsonDecoder.decode(StytchAPIError.self, from: data)
        } catch _ {
            var message = (500..<600).contains(statusCode) ?
                "Server networking error." :
                "Client networking error."

            String(data: data, encoding: .utf8).map { debugInfo in
                message.append(" Debug info: \(debugInfo)")
            }

            error = StytchAPIError(
                statusCode: statusCode,
                errorType: "unknown_error",
                errorMessage: message
            )
        }

        throw error
    }
}
