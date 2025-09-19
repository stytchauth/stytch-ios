import Foundation

// swiftlint:disable type_contents_order

protocol NetworkingClient {
    func configureDFP(dfpEnabled: Bool, dfpAuthMode: DFPProtectedAuthMode?)
    func handleRequest(request: URLRequest, useDFPPA: Bool) async throws -> (Data, HTTPURLResponse)
}

extension NetworkingClient {
    var headers: [String: String] {
        guard let configuration = Current.localStorage.stytchClientConfiguration else {
            return [:]
        }

        let clientInfoString = try? Current.clientInfo.base64EncodedString(encoder: Current.jsonEncoder)

        let publicToken = configuration.publicToken

        let authToken: String
        if let sessionToken = Current.sessionManager.sessionToken?.value, sessionToken.isEmpty == false {
            authToken = "\(publicToken):\(sessionToken)".base64Encoded()
        } else {
            authToken = "\(publicToken):\(publicToken)".base64Encoded()
        }

        return [
            "Content-Type": "application/json",
            "Authorization": "Basic \(authToken)",
            "X-SDK-Client": clientInfoString ?? "",
        ]
    }

    func performRequest(method: HTTPMethod, url: URL, useDFPPA: Bool) async throws -> (Data, HTTPURLResponse) {
        let request = urlRequest(url: url, method: method)
        return try await handleRequest(request: request, useDFPPA: useDFPPA)
    }

    func urlRequest(url: URL, method: HTTPMethod) -> URLRequest {
        var request: URLRequest = .init(url: url)

        request.httpMethod = method.stringValue

        headers.forEach { field, value in
            request.addValue(value, forHTTPHeaderField: field)
        }

        switch method {
        case .get, .delete:
            break
        case let .post(data), let .put(data):
            request.httpBody = data
        }

        return request
    }
}

final class NetworkingClientImplementation: NetworkingClient {
    let networkRequestHandler: NetworkRequestHandler

    private(set) var dfpEnabled: Bool = false
    private(set) var dfpAuthMode = DFPProtectedAuthMode.observation

    init(networkRequestHandler: NetworkRequestHandler) {
        self.networkRequestHandler = networkRequestHandler
    }

    func configureDFP(dfpEnabled: Bool, dfpAuthMode: DFPProtectedAuthMode?) {
        self.dfpEnabled = dfpEnabled
        self.dfpAuthMode = dfpAuthMode ?? .observation
    }

    func handleRequest(request: URLRequest, useDFPPA: Bool) async throws -> (Data, HTTPURLResponse) {
        #if canImport(StytchDFP)
        if useDFPPA == true {
            if dfpEnabled == true {
                switch dfpAuthMode {
                case .observation:
                    return try await networkRequestHandler.handleDFPObservationMode(request: request)
                case .decisioning:
                    return try await networkRequestHandler.handleDFPDecisioningMode(request: request)
                }
            } else {
                return try await networkRequestHandler.handleDFPDisabled(request: request)
            }
        } else {
            return try await networkRequestHandler.defaultRequestHandler(request: request)
        }
        #else
        return try await networkRequestHandler.defaultRequestHandler(request: request)
        #endif
    }

    static var live = NetworkingClientImplementation(networkRequestHandler: NetworkRequestHandlerImplementation(urlSession: .init(configuration: .default)))
}

enum HTTPMethod {
    case delete
    case get
    case post(Data?)
    case put(Data?)

    var stringValue: String {
        switch self {
        case .delete:
            return "DELETE"
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        }
    }
}
