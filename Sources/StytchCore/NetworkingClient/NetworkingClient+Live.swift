import Foundation

extension NetworkingClient {
    static func live(networkRequestHandler: NetworkRequestHandler = NetworkRequestHandlerImplementation()) -> NetworkingClient {
        #if os(iOS)
        @Dependency(\.dfpClient) var dfpClient
        @Dependency(\.captcha) var captcha
        #endif
        let session: URLSession = .init(configuration: .default)
        func defaultRequestHandler(session: URLSession, request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            if #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *) {
                do {
                    let (data, response) = try await session.data(for: request)
                    guard let response = response as? HTTPURLResponse else {
                        throw StytchAPISchemaError(message: "Request does not match expected schema.")
                    }
                    return (data, response)
                } catch {
                    throw StytchAPIUnreachableError(message: "Invalid or no response from server")
                }
            } else {
                return try await withCheckedThrowingContinuation { continuation in
                    let task = session.dataTask(with: request) { data, response, error in
                        if error != nil {
                            continuation.resume(with: .failure(StytchAPIUnreachableError(message: "Invalid or no response from server")))
                            return
                        }
                        guard let data = data, let response = response as? HTTPURLResponse else {
                            continuation.resume(with: .failure(StytchAPISchemaError(message: "Request does not match expected schema.")))
                            return
                        }
                        continuation.resume(with: .success((data, response)))
                    }
                    task.resume()
                }
            }
        }
        return .init { request, dfpEnabled, dfpAuthMode, publicToken in
            #if os(iOS)
            if request.url?.path.contains("/events") == true {
                return try await defaultRequestHandler(session: session, request: request)
            }
            if !dfpEnabled {
                return try await networkRequestHandler.handleDFPDisabled(session: session, request: request, captcha: captcha, requestHandler: defaultRequestHandler)
            }
            switch dfpAuthMode {
            case .observation:
                return try await networkRequestHandler.handleDFPObservationMode(session: session, request: request, publicToken: publicToken, captcha: captcha, dfp: dfpClient, requestHandler: defaultRequestHandler)
            case .decisioning:
                return try await networkRequestHandler.handleDFPDecisioningMode(session: session, request: request, publicToken: publicToken, captcha: captcha, dfp: dfpClient, requestHandler: defaultRequestHandler)
            }
            #endif
            return try await defaultRequestHandler(session: session, request: request)
        }
    }
}
