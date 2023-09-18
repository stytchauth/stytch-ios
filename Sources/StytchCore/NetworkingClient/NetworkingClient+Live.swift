import Foundation

extension NetworkingClient {
    static let live: NetworkingClient = {
        var dfpAvailable: Bool {
            #if os(macOS)
            false
            #elseif os(tvOS)
            false
            #elseif os(watchOS)
            false
            #else
            true
            #endif
        }
        #if dfpAvailable
        @Dependency(\.dfpClient) var dfpClient
        @Dependency(\.captcha) var captcha
        #endif
        let session: URLSession = .init(configuration: .default)
        return .init { request, dfpEnabled, dfpAuthMode, publicToken in
            #if dfpAvailable
            if !dfpEnabled {
                return try await handleDFPDisabled(session: session, request: request, captcha: captcha)
            }
            switch dfpAuthMode {
            case .observation:
                return try await handleDFPObservationMode(session: session, request: request, dfp: dfpClient, captcha: captcha, publicToken: publicToken)
            case .decisioning:
                return try await handleDFPDecisioningMode(session: session, request: request, dfp: dfpClient, captcha: captcha, publicToken: publicToken)
            }
            #endif
            return try await makeRequest(session: session, request: request)
        }
    }()
}

private func makeRequest(session: URLSession, request: URLRequest) async throws -> (Data, HTTPURLResponse) {
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

private func handleDFPDisabled(session: URLSession, request: URLRequest, captcha: CAPTCHA) async throws -> (Data, HTTPURLResponse) {
    // DISABLED = if captcha client is configured, add a captcha token, else do nothing
    if captcha.recaptchaClient == nil {
        return try await makeRequest(session: session, request: request)
    }
    var newRequest = request
    let oldBody = newRequest.httpBody ?? Data()
    var newBody = try JSONSerialization.jsonObject(with: oldBody) as? [String: AnyObject] ?? [:]
    newBody["captcha_token"] = try await captcha.executeRecaptcha() as AnyObject
    newRequest.httpBody = try JSONSerialization.data(withJSONObject: newBody)
    return try await makeRequest(session: session, request: newRequest)
}

private func handleDFPObservationMode(session: URLSession, request: URLRequest, dfp: DFPClient, captcha: CAPTCHA, publicToken: String) async throws -> (Data, HTTPURLResponse) {
    // OBSERVATION = Always DFP; CAPTCHA if configured
    var newRequest = request
    let oldBody = newRequest.httpBody ?? Data()
    var newBody = try JSONSerialization.jsonObject(with: oldBody) as? [String: AnyObject] ?? [:]
    newBody["dfp_telemetry_id"] = try await dfp.getTelemetryId(publicToken) as AnyObject
    if captcha.recaptchaClient != nil {
        newBody["captcha_token"] = try await captcha.executeRecaptcha() as AnyObject
    }
    newRequest.httpBody = try JSONSerialization.data(withJSONObject: newBody)
    return try await makeRequest(session: session, request: newRequest)
}

private func handleDFPDecisioningMode(session: URLSession, request: URLRequest, dfp: DFPClient, captcha: CAPTCHA, publicToken: String) async throws -> (Data, HTTPURLResponse) {
    // DECISIONING = add DFP Id, proceed; if request 403s, add a captcha token
    var firstRequest = request
    let oldBody = firstRequest.httpBody ?? Data()
    var firstRequestBody = try JSONSerialization.jsonObject(with: oldBody) as? [String: AnyObject] ?? [:]
    firstRequestBody["dfp_telemetry_id"] = try await dfp.getTelemetryId(publicToken) as AnyObject
    firstRequest.httpBody = try JSONSerialization.data(withJSONObject: firstRequestBody)
    let (data, response) = try await makeRequest(session: session, request: firstRequest)
    if response.statusCode != 403 {
        return (data, response)
    }
    var secondRequest = request
    var secondRequstBody = try JSONSerialization.jsonObject(with: oldBody) as? [String: AnyObject] ?? [:]
    secondRequstBody["dfp_telemetry_id"] = try await dfp.getTelemetryId(publicToken) as AnyObject
    secondRequstBody["captcha_token"] = try await captcha.executeRecaptcha() as AnyObject
    secondRequest.httpBody = try JSONSerialization.data(withJSONObject: secondRequstBody)
    return try await makeRequest(session: session, request: secondRequest)
}
