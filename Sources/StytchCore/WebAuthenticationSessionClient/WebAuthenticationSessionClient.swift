import AuthenticationServices

#if !os(watchOS)
@available(tvOS 16.0, *)
struct WebAuthenticationSessionClient {
    private let initiate: (Parameters) async throws -> (token: String, url: URL)

    init(initiate: @MainActor @escaping (Parameters) async throws -> (token: String, url: URL)) {
        self.initiate = initiate
    }

    @MainActor
    func initiate(
        parameters: Parameters
    ) async throws -> (token: String, url: URL) {
        try await initiate(parameters)
    }
}

@available(tvOS 16.0, *)
extension WebAuthenticationSessionClient {
    struct Parameters {
        let url: URL
        let callbackUrlScheme: String
        #if !os(tvOS)
        let presentationContextProvider: ASWebAuthenticationPresentationContextProviding
        #endif
    }
}
#endif
