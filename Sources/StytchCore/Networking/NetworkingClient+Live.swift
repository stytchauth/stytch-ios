import Foundation

extension NetworkingClient {
    static func live(networkRequestHandler: NetworkRequestHandler = NetworkRequestHandlerImplementation(urlSession: .init(configuration: .default))) -> NetworkingClient {
        .init { request, dfpEnabled, dfpAuthMode, useDFPPA in
            #if os(iOS)
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
            #endif

            return try await networkRequestHandler.defaultRequestHandler(request: request)
        }
    }
}
