import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension StytchClient.OAuth {
    public struct GenericProvider {
        let provider: Provider

        public func start(parameters: StartParameters) async throws {
            guard let publicToken = StytchClient.instance.configuration?.publicToken else { throw StytchError.pckeNotAvailable } // TODO: fix error

            var queryParameters = [
                ("code_challenge", try StytchClient.generateAndStorePKCE(keychainItem: .oauthPKCECodeVerifier).challenge),
                ("public_token", publicToken),
            ]

            [
                ("login_redirect_url", parameters.loginRedirectUrl?.absoluteString),
                ("signup_redirect_url", parameters.signupRedirectUrl?.absoluteString),
                ("custom_scopes", parameters.customScopes?.joined(separator: " ")),
            ].forEach { name, value in
                guard let value = value else { return }
                queryParameters.append((name, value))
            }

            let subDomain = publicToken.hasPrefix("public-token-test") ? "test" : "live"

            guard
                let url = URL(string: "https://\(subDomain).stytch.com/v1/public/oauth/\(provider.rawValue)/start")?.appending(queryParameters: queryParameters)
            else { throw StytchError.oauthInvalidStartUrl }

            DispatchQueue.main.async {
                #if os(macOS)
                NSWorkspace.shared.open(url)
                #else
                UIApplication.shared.open(url)
                #endif
            }
        }

        public struct StartParameters: Encodable {
            let loginRedirectUrl: URL?
            let signupRedirectUrl: URL?
            let customScopes: [String]?

            public init(
                loginRedirectUrl: URL? = nil,
                signupRedirectUrl: URL? = nil,
                customScopes: [String]? = nil
            ) {
                self.loginRedirectUrl = loginRedirectUrl
                self.signupRedirectUrl = signupRedirectUrl
                self.customScopes = customScopes
            }
        }
    }
}

extension StytchClient.OAuth.GenericProvider {
    enum Provider: String {
        case facebook
        case google
        // TODO: - add more providers
    }
}

//extension StytchClient.OAuth.GenericProvider {
//    static var session: ASWebAuthenticationSession!
//
//    static let provider: Provider = .init()
//
//    func presentASWebAuth(url: URL) {
//            Self.session = ASWebAuthenticationSession(url: url, callbackURLScheme: "stytch-demo") { url, error in
//                print(url)
//                // This doesn't seem to be getting called, though the app is redirected into. perhaps a config thing or just how Stytch redirects doesn't play well w/ ASWebAuth
//                // perhaps call authenticate here?
//            }
//
//            Self.session.presentationContextProvider = Self.provider
//
//            DispatchQueue.main.async {
//                Self.session.start()
//            }
//    }
//}
//
//final class Provider: NSObject, ASWebAuthenticationPresentationContextProviding {
//    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
//        UIApplication.shared.keyWindow!
//    }
//}
