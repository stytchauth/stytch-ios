import AuthenticationServices

struct WebAuthenticationSessionClient {
    private let initiate: (URL, String, ASWebAuthenticationPresentationContextProviding) async throws -> (token: String, url: URL)

    init(initiate: @escaping @MainActor (URL, String, ASWebAuthenticationPresentationContextProviding) async throws -> (token: String, url: URL)) {
        self.initiate = initiate
    }

    @MainActor
    func initiate(
        url: URL,
        callbackUrlScheme: String,
        presentationContextProvider: ASWebAuthenticationPresentationContextProviding
    ) async throws -> (token: String, url: URL) {
        try await initiate(url, callbackUrlScheme, presentationContextProvider)
    }
}
