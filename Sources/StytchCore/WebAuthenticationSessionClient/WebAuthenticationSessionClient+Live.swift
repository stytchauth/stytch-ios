import AuthenticationServices

#if !os(watchOS)
@available(tvOS 16.0, *)
extension WebAuthenticationSessionClient {
    static let live: Self = .init { parameters in
        try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(url: parameters.url, callbackURLScheme: parameters.callbackUrlScheme) { url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let url = url else {
                    continuation.resume(throwing: StytchSDKError.missingURL)
                    return
                }
                do {
                    if parameters.clientType == ClientType.consumer {
                        guard let token = try StytchClient.tokenValues(for: url)?.2 else {
                            continuation.resume(throwing: StytchSDKError.deeplinkMissingToken)
                            return
                        }
                        continuation.resume(returning: (token, url))
                    } else {
                        guard let token = try StytchB2BClient.tokenValues(for: url)?.2 else {
                            continuation.resume(throwing: StytchSDKError.deeplinkMissingToken)
                            return
                        }
                        continuation.resume(returning: (token, url))
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            #if !os(tvOS)
            session.presentationContextProvider = parameters.presentationContextProvider
            #endif
            session.start()
        }
    }
}
#endif

#if !os(tvOS) && !os(watchOS)
extension WebAuthenticationSessionClient {
    final class DefaultPresentationProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
        @MainActor
        func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
            .init()
        }
    }
}
#endif
