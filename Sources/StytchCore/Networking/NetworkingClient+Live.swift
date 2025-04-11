import Foundation

extension NetworkingClient {
    static func live(networkRequestHandler: NetworkRequestHandler = NetworkRequestHandlerImplementation(urlSession: .init(configuration: .default))) -> NetworkingClient {
        .init { request, dfpEnabled, dfpAuthMode, publicToken, dfppaDomain, useDFPPA in
            #if os(iOS)
            if useDFPPA == true {
                if dfpEnabled == true {
                    switch dfpAuthMode {
                    case .observation:
                        return try await networkRequestHandler.handleDFPObservationMode(request: request, publicToken: publicToken, dfppaDomain: dfppaDomain)
                    case .decisioning:
                        return try await networkRequestHandler.handleDFPDecisioningMode(request: request, publicToken: publicToken, dfppaDomain: dfppaDomain)
                    }
                } else {
                    return try await networkRequestHandler.handleDFPDisabled(request: request)
                }
            } else {
                return try await networkRequestHandler.defaultRequestHandler(request)
            }
            #endif

            return try await networkRequestHandler.defaultRequestHandler(request)
        }
    }
}
