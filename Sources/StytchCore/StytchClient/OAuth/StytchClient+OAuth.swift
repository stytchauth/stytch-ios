import Foundation

public extension StytchClient {
    /// docs
    struct OAuth {
        let router: NetworkingRouter<OAuthRoute>

        public var apple: Apple { .init(router: router.scopedRouter(OAuthRoute.apple))}
    }
}

public extension StytchClient {
    /// The interface for interacting with OAuth products.
    static var oauth: OAuth { .init(router: router.scopedRouter(BaseRoute.oauth)) }
}

enum FacebookRoute: RouteType {
    case authenticate

    var path: Path {
        "authenticate"
    }
}

enum GoogleRoute: RouteType {
    case authenticate

    var path: Path {
        "authenticate"
    }
}

import AuthenticationServices

enum AppleRoute: RouteType {
    case authenticate

    var path: Path {
        "authenticate" // FIXME: - do better
    }
}

public extension StytchClient.OAuth {
    struct Apple {
        let router: NetworkingRouter<AppleRoute>

        public func authenticate(presentationContextProvider: ASAuthorizationControllerPresentationContextProviding? = nil) async throws -> AuthenticateResponseType {
            let nonce = try Current.cryptoClient.dataWithRandomBytesOfCount(32)
            let idToken = try await Current.appleOAuthClient.authenticate(
                presentationContextProvider: presentationContextProvider,
                nonce: Current.cryptoClient.sha256(nonce).base64EncodedString()
            )
            return try await router.post(
                to: .authenticate,
                parameters: AuthenticateParameters(nonce: nonce, idToken: idToken)
            ) as AuthenticateResponse
        }

        struct AuthenticateParameters: Codable {
            let nonce: Data
            let idToken: Data
        }
    }
}

extension StytchClient.Environment {
    var appleOAuthClient: AppleOAuthClient { .instance }
}

final class AppleOAuthClient: NSObject, ASAuthorizationControllerDelegate {
    static let instance: AppleOAuthClient = .init()

    private var continuation: CheckedContinuation<Data, Error>?

    func authenticate(presentationContextProvider: ASAuthorizationControllerPresentationContextProviding? = nil, nonce: String) async throws -> Data {
        let provider: ASAuthorizationAppleIDProvider = .init()
        let request = provider.createRequest()
        request.requestedScopes = [.email, .fullName]
        request.nonce = nonce

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.presentationContextProvider = presentationContextProvider
        controller.delegate = self

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            controller.performRequests()
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: Blah.error)
            return
        }
        guard let token = credential.identityToken else {
            continuation?.resume(throwing: Blah.error)
            return
        }
        continuation?.resume(returning: token)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
    }

    enum Blah: Error { case error }
}
