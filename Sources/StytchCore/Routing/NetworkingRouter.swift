import Foundation

protocol RouteType {
    var path: Path { get }
}

struct NetworkingRouter<Route: RouteType> {
    // Provides simpler ergonomics for deeply-nested routes
    let routeType: Route.Type = Route.self
    
    private let getConfiguration: () -> Configuration?
    private let pathForRoute: (Route) -> Path

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

extension NetworkingRouter {
    func post<Parameters: Encodable, Response: Decodable>(
        to route: Route,
        parameters: Parameters
    ) async throws -> Response {
        try await performRequest(.post(Current.jsonEncoder.encode(parameters)), route: route)
    }

    func put<Parameters: Encodable, Response: Decodable>(
        to route: Route,
        parameters: Parameters
    ) async throws -> Response {
        try await performRequest(.put(Current.jsonEncoder.encode(parameters)), route: route)
    }

    func get<Response: Decodable>(route: Route) async throws -> Response {
        try await performRequest(.get, route: route)
    }

    func delete<Response: Decodable>(route: Route) async throws -> Response {
        try await performRequest(.delete, route: route)
    }

    private func performRequest<Response: Decodable>(
        _ method: NetworkingClient.Method,
        route: Route
    ) async throws -> Response {
        guard let configuration = getConfiguration() else {
            throw StytchError.clientNotConfigured
        }

        let (data, response) = try await Current.networkingClient.performRequest(
            method,
            url: configuration.baseUrl.appendingPathComponent(path(for: route).rawValue)
        )
        do {
            try response.verifyStatus(data: data)
            let dataContainer = try Current.jsonDecoder.decode(DataContainer<Response>.self, from: data)
            if let sessionResponse = dataContainer.data as? AuthenticateResponseType {
                Current.sessionStorage.updateSession(
                    .user(sessionResponse.session),
                    tokens: [
                        .jwt(sessionResponse.sessionJwt),
                        .opaque(sessionResponse.sessionToken),
                    ],
                    hostUrl: configuration.hostUrl
                )
                Current.localStorage.user = sessionResponse.user
            } else if let sessionResponse = dataContainer.data as? B2BAuthenticateResponseType {
                Current.sessionStorage.updateSession(
                    .member(sessionResponse.memberSession),
                    tokens: [
                        .jwt(sessionResponse.sessionJwt),
                        .opaque(sessionResponse.sessionToken),
                    ],
                    hostUrl: configuration.hostUrl
                )
                Current.localStorage.member = sessionResponse.member
            }
            return dataContainer.data
        } catch let error as StytchError where error.statusCode == 401 {
            Current.sessionStorage.reset()
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
    func verifyStatus(data: Data) throws {
        guard (400..<600).contains(statusCode) else { return }

        let error: Error

        do {
            error = try Current.jsonDecoder.decode(StytchError.self, from: data)
        } catch _ {
            var message = (500..<600).contains(statusCode) ?
                "Server networking error." :
                "Client networking error."

            String(data: data, encoding: .utf8).map { debugInfo in
                message.append(" Debug info: \(debugInfo)")
            }

            error = StytchError(
                statusCode: statusCode,
                errorType: "unknown_error",
                errorMessage: message
            )
        }

        throw error
    }
}
