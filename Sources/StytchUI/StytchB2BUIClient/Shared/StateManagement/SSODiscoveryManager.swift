import Foundation
import StytchCore

// swiftlint:disable type_contents_order

struct SSOConnectionsResponse: Decodable {
    let data: DataWrapper

    struct DataWrapper: Decodable {
        let connections: [StytchB2BClient.SSOActiveConnection]
    }
}

enum SSODiscoveryManager {
    private(set) static var ssoActiveConnections: [StytchB2BClient.SSOActiveConnection] = []

    static func fetchSSODiscoveryConnections(_ emailAddress: String) async throws -> [StytchB2BClient.SSOActiveConnection] {
        guard let publicToken = StytchB2BClient.configuration?.publicToken else {
            throw StytchSDKError.B2BSDKNotConfigured
        }

        guard let baseUrl = StytchB2BClient.configuration?.baseUrl else {
            throw URLError(.badURL)
        }

        let parameters = ["email_address": emailAddress]
        let fullUrlString = "\(baseUrl)b2b/sso/discovery/connections?\(parameters.toURLParameters())"
        guard let fullUrl = URL(string: fullUrlString) else {
            throw URLError(.badURL)
        }

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601

        let clientInfo = ClientInfo()
        let clientInfoString = (try? encoder.encode(clientInfo))?.base64EncodedString()
        let authToken = Data("\(publicToken):\(publicToken)".utf8).base64EncodedString()
        let allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Authorization": "Basic \(authToken)",
            "X-SDK-Client": clientInfoString ?? "",
        ]

        var request = URLRequest(url: fullUrl)
        request.httpMethod = "GET"
        allHTTPHeaderFields.forEach { field, value in
            request.addValue(value, forHTTPHeaderField: field)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let (data, _) = try await URLSession.shared.data(for: request)
        let ssoConnectionsResponse = try decoder.decode(SSOConnectionsResponse.self, from: data)
        ssoActiveConnections = ssoConnectionsResponse.data.connections
        return ssoActiveConnections
    }

    static func reset() {
        ssoActiveConnections = []
    }
}
