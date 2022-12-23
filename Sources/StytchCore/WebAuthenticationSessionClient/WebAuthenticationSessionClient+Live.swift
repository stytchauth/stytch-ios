import AuthenticationServices

extension WebAuthenticationSessionClient {
    static let live: Self = .init { url, callbackUrlScheme, presentationContextProvider in
        try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackUrlScheme) { url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let url = url else {
                    continuation.resume(throwing: StytchError.oauthASWebAuthMissingUrl)
                    return
                }
                do {
                    guard let token = try StytchClient.tokenValues(for: url)?.1 else {
                        continuation.resume(throwing: StytchError.missingDeeplinkToken)
                        return
                    }
                    continuation.resume(returning: (token, url))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            session.presentationContextProvider = presentationContextProvider
            session.start()
        }
    }
}

extension WebAuthenticationSessionClient {
    final class DefaultPresentationProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
        @MainActor
        func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
            .init()
        }
    }
}
