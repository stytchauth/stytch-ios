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
                let (data, response) = try await session.data(for: request)
                guard let response = response as? HTTPURLResponse else { throw NetworkingClient.Error.nonHttpResponse }
                return (data, response)
            } else {
                return try await withCheckedThrowingContinuation { continuation in
                    let task = session.dataTask(with: request) { data, response, error in
                        if let error = error {
                            continuation.resume(with: .failure(error))
                            return
                        }
                        guard let data = data else {
                            continuation.resume(with: .failure(NetworkingClient.Error.missingData))
                            return
                        }
                        guard let response = response as? HTTPURLResponse else {
                            continuation.resume(with: .failure(NetworkingClient.Error.nonHttpResponse))
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
