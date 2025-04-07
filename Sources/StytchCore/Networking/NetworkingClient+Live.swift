import Foundation

extension NetworkingClient {
    static func live(networkRequestHandler: NetworkRequestHandler = NetworkRequestHandlerImplementation()) -> NetworkingClient {
        #if os(iOS)
        @Dependency(\.dfpClient) var dfpClient
        @Dependency(\.captcha) var captcha
        #endif
        let session: URLSession = .init(configuration: .default)

        return .init { request, dfpEnabled, dfpAuthMode, publicToken, dfppaDomain, useDFPPA in
            #if os(iOS)
            if request.url?.path.contains("/events") == true {
                return try await defaultRequestHandler(session: session, request: request)
            }
            if dfpEnabled == true, useDFPPA == true {
                switch dfpAuthMode {
                case .observation:
                    return try await networkRequestHandler.handleDFPObservationMode(session: session, request: request, publicToken: publicToken, dfppaDomain: dfppaDomain, captcha: captcha, dfp: dfpClient, requestHandler: defaultRequestHandler)
                case .decisioning:
                    return try await networkRequestHandler.handleDFPDecisioningMode(session: session, request: request, publicToken: publicToken, dfppaDomain: dfppaDomain, captcha: captcha, dfp: dfpClient, requestHandler: defaultRequestHandler)
                }
            } else {
                return try await networkRequestHandler.handleDFPDisabled(session: session, request: request, captcha: captcha, requestHandler: defaultRequestHandler)
            }
            #endif
            return try await defaultRequestHandler(session: session, request: request)
        }
    }

    private static func defaultRequestHandler(session: URLSession, request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw StytchAPISchemaError(message: "Request does not match expected schema.")
        }
        return (data, response)
    }
}
