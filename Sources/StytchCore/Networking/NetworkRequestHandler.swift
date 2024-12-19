import Foundation

internal protocol NetworkRequestHandler {
    #if os(iOS)
    func handleDFPDisabled(session: URLSession, request: URLRequest, captcha: CaptchaProvider, requestHandler: (URLSession, URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse)

    // swiftlint:disable:next function_parameter_count
    func handleDFPObservationMode(session: URLSession, request: URLRequest, publicToken: String, dfppaDomain: String, captcha: CaptchaProvider, dfp: DFPProvider, requestHandler: (URLSession, URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse)

    // swiftlint:disable:next function_parameter_count
    func handleDFPDecisioningMode(session: URLSession, request: URLRequest, publicToken: String, dfppaDomain: String, captcha: CaptchaProvider, dfp: DFPProvider, requestHandler: (URLSession, URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse)
    #endif
}

internal struct NetworkRequestHandlerImplementation: NetworkRequestHandler {
    #if os(iOS)
    func handleDFPDisabled(session: URLSession, request: URLRequest, captcha: CaptchaProvider, requestHandler: (URLSession, URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse) {
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
    func handleDFPObservationMode(session: URLSession, request: URLRequest, publicToken: String, dfppaDomain: String, captcha: CaptchaProvider, dfp: DFPProvider, requestHandler: (URLSession, URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse) {
        // OBSERVATION = Always DFP; CAPTCHA if configured
        var newRequest = request
        let oldBody = newRequest.httpBody ?? Data("{}".utf8)
        var newBody = try JSONSerialization.jsonObject(with: oldBody) as? [String: AnyObject] ?? [:]
        let telemetryId = await dfp.getTelemetryId(publicToken: publicToken, dfppaDomain: dfppaDomain) as AnyObject
        newBody["dfp_telemetry_id"] = telemetryId
        if captcha.isConfigured() {
            newBody["captcha_token"] = await captcha.executeRecaptcha() as AnyObject
        }
        newRequest.httpBody = try JSONSerialization.data(withJSONObject: newBody)
        return try await requestHandler(session, newRequest)
    }

    // swiftlint:disable:next function_parameter_count
    func handleDFPDecisioningMode(session: URLSession, request: URLRequest, publicToken: String, dfppaDomain: String, captcha: CaptchaProvider, dfp: DFPProvider, requestHandler: (URLSession, URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse) {
        // DECISIONING = add DFP Id, proceed; if request 403s, add a captcha token
        var firstRequest = request
        let oldBody = firstRequest.httpBody ?? Data("{}".utf8)
        var firstRequestBody = try JSONSerialization.jsonObject(with: oldBody) as? [String: AnyObject] ?? [:]
        let telemetryId1 = await dfp.getTelemetryId(publicToken: publicToken, dfppaDomain: dfppaDomain) as AnyObject
        firstRequestBody["dfp_telemetry_id"] = telemetryId1
        firstRequest.httpBody = try JSONSerialization.data(withJSONObject: firstRequestBody)
        let (data, response) = try await requestHandler(session, firstRequest)
        if response.statusCode != 403 {
            return (data, response)
        }
        var secondRequest = request
        var secondRequestBody = try JSONSerialization.jsonObject(with: oldBody) as? [String: AnyObject] ?? [:]
        let telemetryId2 = await dfp.getTelemetryId(publicToken: publicToken, dfppaDomain: dfppaDomain) as AnyObject
        secondRequestBody["dfp_telemetry_id"] = telemetryId2
        secondRequestBody["captcha_token"] = await captcha.executeRecaptcha() as AnyObject
        secondRequest.httpBody = try JSONSerialization.data(withJSONObject: secondRequestBody)
        return try await requestHandler(session, secondRequest)
    }
    #endif
}
