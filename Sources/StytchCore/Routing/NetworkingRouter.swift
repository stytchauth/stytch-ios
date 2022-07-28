import Foundation

protocol RouteType {
    var path: Path { get }
}

struct NetworkingRouter<Route: RouteType> {
    private let pathForRoute: (Route) -> Path

    private init(_ pathForRoute: @escaping (Route) -> Path) {
        self.pathForRoute = pathForRoute
    }

    func childRouter<ChildRoute: RouteType>(
        _ transform: @escaping (ChildRoute) -> Route
    ) -> NetworkingRouter<ChildRoute> {
        .init { path(for: transform($0)) }
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

    func get<Response: Decodable>(route: Route) async throws -> Response {
        try await performRequest(.get, route: route)
    }

    private func performRequest<Response: Decodable>(
        _ method: NetworkingClient.Method,
        route: Route
    ) async throws -> Response {
        guard let configuration = StytchClient.instance.configuration else {
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
                    sessionResponse.session,
                    tokens: [
                        .jwt(sessionResponse.sessionJwt),
                        .opaque(sessionResponse.sessionToken),
                    ],
                    hostUrl: configuration.hostUrl
                )
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

extension NetworkingRouter where Route == BaseRoute {
    init() { self.init { $0.path } }
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
