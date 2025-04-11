import Foundation

// swiftlint:disable type_contents_order

internal protocol NetworkRequestHandler {
    var urlSession: URLSession { get }

    init(urlSession: URLSession)

    #if os(iOS)
    var captchaProvider: CaptchaProvider { get }
    var dfpProvider: DFPProvider { get }

    func handleDFPDisabled(request: URLRequest) async throws -> (Data, HTTPURLResponse)
    func handleDFPObservationMode(request: URLRequest, publicToken: String, dfppaDomain: String) async throws -> (Data, HTTPURLResponse)
    func handleDFPDecisioningMode(request: URLRequest, publicToken: String, dfppaDomain: String) async throws -> (Data, HTTPURLResponse)
    #endif

    func defaultRequestHandler(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

extension NetworkRequestHandler {
    #if os(iOS)
    func handleDFPDisabled(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        // DISABLED = if captcha client is configured, add a captcha token, else do nothing
        if captchaProvider.isConfigured() == false {
            return try await defaultRequestHandler(request)
        }
        var newRequest = request
        if request.httpMethod != "GET", request.httpMethod != "DELETE" {
            let oldBody = newRequest.httpBody ?? Data("{}".utf8)
            var newBody = try JSONSerialization.jsonObject(with: oldBody) as? [String: AnyObject] ?? [:]
            newBody["captcha_token"] = await captchaProvider.executeRecaptcha() as AnyObject
            newRequest.httpBody = try JSONSerialization.data(withJSONObject: newBody)
        }
        return try await defaultRequestHandler(newRequest)
    }

    func handleDFPObservationMode(request: URLRequest, publicToken: String, dfppaDomain: String) async throws -> (Data, HTTPURLResponse) {
        // OBSERVATION = Always DFP; CAPTCHA if configured
        var newRequest = request
        let oldBody = newRequest.httpBody ?? Data("{}".utf8)
        var newBody = try JSONSerialization.jsonObject(with: oldBody) as? [String: AnyObject] ?? [:]
        let telemetryId = await dfpProvider.getTelemetryId(publicToken: publicToken, dfppaDomain: dfppaDomain) as AnyObject
        newBody["dfp_telemetry_id"] = telemetryId
        if captchaProvider.isConfigured() {
            newBody["captcha_token"] = await captchaProvider.executeRecaptcha() as AnyObject
        }
        newRequest.httpBody = try JSONSerialization.data(withJSONObject: newBody)
        return try await defaultRequestHandler(newRequest)
    }

    func handleDFPDecisioningMode(request: URLRequest, publicToken: String, dfppaDomain: String) async throws -> (Data, HTTPURLResponse) {
        // DECISIONING = add DFP Id, proceed; if request 403s, add a captcha token
        var firstRequest = request
        let oldBody = firstRequest.httpBody ?? Data("{}".utf8)
        var firstRequestBody = try JSONSerialization.jsonObject(with: oldBody) as? [String: AnyObject] ?? [:]
        let telemetryId1 = await dfpProvider.getTelemetryId(publicToken: publicToken, dfppaDomain: dfppaDomain) as AnyObject
        firstRequestBody["dfp_telemetry_id"] = telemetryId1
        firstRequest.httpBody = try JSONSerialization.data(withJSONObject: firstRequestBody)
        let (data, response) = try await defaultRequestHandler(firstRequest)
        if response.statusCode != 403 {
            return (data, response)
        }
        var secondRequest = request
        var secondRequestBody = try JSONSerialization.jsonObject(with: oldBody) as? [String: AnyObject] ?? [:]
        let telemetryId2 = await dfpProvider.getTelemetryId(publicToken: publicToken, dfppaDomain: dfppaDomain) as AnyObject
        secondRequestBody["dfp_telemetry_id"] = telemetryId2
        secondRequestBody["captcha_token"] = await captchaProvider.executeRecaptcha() as AnyObject
        secondRequest.httpBody = try JSONSerialization.data(withJSONObject: secondRequestBody)
        return try await defaultRequestHandler(secondRequest)
    }
    #endif
}

internal struct NetworkRequestHandlerImplementation: NetworkRequestHandler {
    let urlSession: URLSession

    #if os(iOS)
    var captchaProvider: CaptchaProvider {
        Current.captcha
    }

    var dfpProvider: DFPProvider {
        Current.dfpClient
    }
    #endif

    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    func defaultRequestHandler(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await urlSession.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw StytchAPISchemaError(message: "Request does not match expected schema.")
        }
        return (data, response)
    }
}
