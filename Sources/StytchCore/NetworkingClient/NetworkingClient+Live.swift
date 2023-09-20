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

internal protocol NetworkRequestHandler {
    #if os(iOS)
    func handleDFPDisabled(session: URLSession, request: URLRequest, captcha: CAPTCHA, requestHandler: (URLSession, URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse)

    // swiftlint:disable:next function_parameter_count
    func handleDFPObservationMode(session: URLSession, request: URLRequest, publicToken: String, captcha: CAPTCHA, dfp: DFPClient, requestHandler: (URLSession, URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse)

    // swiftlint:disable:next function_parameter_count
    func handleDFPDecisioningMode(session: URLSession, request: URLRequest, publicToken: String, captcha: CAPTCHA, dfp: DFPClient, requestHandler: (URLSession, URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse)
    #endif
}

internal struct NetworkRequestHandlerImplementation: NetworkRequestHandler {
    #if os(iOS)
    func handleDFPDisabled(session: URLSession, request: URLRequest, captcha: CAPTCHA, requestHandler: (URLSession, URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse) {
        // DISABLED = if captcha client is configured, add a captcha token, else do nothing
        if captcha.isConfigured() == false {
            return try await requestHandler(session, request)
        }
        var newRequest = request
        let oldBody = newRequest.httpBody ?? Data("{}".utf8)
        var newBody = try JSONSerialization.jsonObject(with: oldBody) as? [String: AnyObject] ?? [:]
        newBody["captcha_token"] = await captcha.executeRecaptcha() as AnyObject
        newRequest.httpBody = try JSONSerialization.data(withJSONObject: newBody)
        return try await requestHandler(session, newRequest)
    }

    // swiftlint:disable:next function_parameter_count
    func handleDFPObservationMode(session: URLSession, request: URLRequest, publicToken: String, captcha: CAPTCHA, dfp: DFPClient, requestHandler: (URLSession, URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse) {
        // OBSERVATION = Always DFP; CAPTCHA if configured
        var newRequest = request
        let oldBody = newRequest.httpBody ?? Data("{}".utf8)
        var newBody = try JSONSerialization.jsonObject(with: oldBody) as? [String: AnyObject] ?? [:]
        newBody["dfp_telemetry_id"] = await dfp.getTelemetryId(publicToken: publicToken) as AnyObject
        if captcha.isConfigured() {
            newBody["captcha_token"] = await captcha.executeRecaptcha() as AnyObject
        }
        newRequest.httpBody = try JSONSerialization.data(withJSONObject: newBody)
        return try await requestHandler(session, newRequest)
    }

    // swiftlint:disable:next function_parameter_count
    func handleDFPDecisioningMode(session: URLSession, request: URLRequest, publicToken: String, captcha: CAPTCHA, dfp: DFPClient, requestHandler: (URLSession, URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse) {
        // DECISIONING = add DFP Id, proceed; if request 403s, add a captcha token
        var firstRequest = request
        let oldBody = firstRequest.httpBody ?? Data("{}".utf8)
        var firstRequestBody = try JSONSerialization.jsonObject(with: oldBody) as? [String: AnyObject] ?? [:]
        firstRequestBody["dfp_telemetry_id"] = await dfp.getTelemetryId(publicToken: publicToken) as AnyObject
        firstRequest.httpBody = try JSONSerialization.data(withJSONObject: firstRequestBody)
        let (data, response) = try await requestHandler(session, firstRequest)
        if response.statusCode != 403 {
            return (data, response)
        }
        var secondRequest = request
        var secondRequestBody = try JSONSerialization.jsonObject(with: oldBody) as? [String: AnyObject] ?? [:]
        secondRequestBody["dfp_telemetry_id"] = await dfp.getTelemetryId(publicToken: publicToken) as AnyObject
        secondRequestBody["captcha_token"] = await captcha.executeRecaptcha() as AnyObject
        secondRequest.httpBody = try JSONSerialization.data(withJSONObject: secondRequestBody)
        return try await requestHandler(session, secondRequest)
    }
    #endif
}
