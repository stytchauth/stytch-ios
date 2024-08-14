import Foundation
import Combine

public protocol RouteType {
    var path: Path { get }
}

public struct NetworkingRouter<Route: RouteType> {
    private let getConfiguration: () -> Configuration?

    private let pathForRoute: (Route) -> Path

    @Dependency(\.jsonEncoder) private var jsonEncoder

    @Dependency(\.jsonDecoder) private var jsonDecoder

    @Dependency(\.networkingClient) private var networkingClient

    @Dependency(\.sessionStorage) private var sessionStorage

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
    func post<Response: Decodable>(
        to route: Route
    ) async throws -> Response {
        try await performRequest(.post(nil), route: route)
    }

    func post<Parameters: Encodable, Response: Decodable>(
        to route: Route,
        parameters: Parameters
    ) async throws -> Response {
        try await performRequest(.post(jsonEncoder.encode(parameters)), route: route)
    }

    func post<Parameters: Encodable>(
        to route: Route,
        parameters: Parameters
    ) async throws {
        try await performRequest(.post(jsonEncoder.encode(parameters)), route: route)
    }

    func put<Parameters: Encodable, Response: Decodable>(
        to route: Route,
        parameters: Parameters
    ) async throws -> Response {
        try await performRequest(.put(jsonEncoder.encode(parameters)), route: route)
    }

    func get<Response: Decodable>(route: Route) async throws -> Response {
        try await performRequest(.get, route: route)
    }

    func delete<Response: Decodable>(route: Route) async throws -> Response {
        try await performRequest(.delete, route: route)
    }

    private func performRequest(
        _ method: NetworkingClient.Method,
        route: Route
    ) async throws {
        guard let configuration = getConfiguration() else {
            throw StytchSDKError.consumerSDKNotConfigured
        }

        let (data, response) = try await networkingClient.performRequest(
            method,
            url: configuration.baseUrl.appendingPathComponent(path(for: route).rawValue)
        )
        do {
            try response.verifyStatus(data: data, jsonDecoder: jsonDecoder)
        } catch let error as StytchAPIError where error.statusCode == 401 {
            sessionStorage.reset()
            throw error
        } catch {
            throw error
        }
    }

    private func performRequest<Response: Decodable>(
        _ method: NetworkingClient.Method,
        route: Route
    ) async throws -> Response {
        guard let configuration = getConfiguration() else {
            throw StytchSDKError.consumerSDKNotConfigured
        }
        let url = configuration.baseUrl.appendingPathComponent(path(for: route).rawValue)
        let (data, response) = try await networkingClient.performRequest(method, url: url)

        do {
            try response.verifyStatus(data: data, jsonDecoder: jsonDecoder)
            let dataContainer = try jsonDecoder.decode(DataContainer<Response>.self, from: data)
            if let sessionResponse = dataContainer.data as? AuthenticateResponseType {
                sessionStorage.updateSession(
                    sessionType: .user(sessionResponse.session),
                    tokens: SessionTokens(jwt: .jwt(sessionResponse.sessionJwt), opaque: .opaque(sessionResponse.sessionToken)),
                    hostUrl: configuration.hostUrl
                )
                userStorage.update(sessionResponse.user)
                // if we have a local biometric registration that doesn't exist on the user object, delete the local
                if let queryResult: KeychainClient.QueryResult = try? keychainClient.get(.privateKeyRegistration).first,
                   let biometricRegistrationId = try? queryResult.generic.map({ try jsonDecoder.decode(KeychainClient.KeyRegistration.self, from: $0) }),
                   !sessionResponse.user.biometricRegistrations.map({ $0.id }).contains(biometricRegistrationId.registrationId)
                {
                    try? keychainClient.removeItem(.privateKeyRegistration)
                }
            } else if let sessionResponse = dataContainer.data as? B2BAuthenticateResponseType {
                sessionStorage.updateSession(
                    sessionType: .member(sessionResponse.memberSession),
                    tokens: SessionTokens(jwt: .jwt(sessionResponse.sessionJwt), opaque: .opaque(sessionResponse.sessionToken)),
                    hostUrl: configuration.hostUrl
                )
                memberStorage.update(sessionResponse.member)
                organizationStorage.update(sessionResponse.organization)
            } else if let sessionResponse = dataContainer.data as? B2BMFAAuthenticateResponseType {
                if let memberSession = sessionResponse.memberSession {
                    sessionStorage.updateSession(
                        sessionType: .member(memberSession),
                        tokens: SessionTokens(jwt: .jwt(sessionResponse.sessionJwt), opaque: .opaque(sessionResponse.sessionToken)),
                        hostUrl: configuration.hostUrl
                    )
                } else {
                    sessionStorage.updateSession(
                        intermediateSessionToken: sessionResponse.intermediateSessionToken
                    )
                }
                memberStorage.update(sessionResponse.member)
                organizationStorage.update(sessionResponse.organization)
            } else if let sessionResponse = dataContainer.data as? DiscoveryIntermediateSessionTokenDataType {
                sessionStorage.updateSession(
                    intermediateSessionToken: sessionResponse.intermediateSessionToken
                )
            }
            return dataContainer.data
        } catch let error as StytchAPIError where error.statusCode == 401 {
            sessionStorage.reset()
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
