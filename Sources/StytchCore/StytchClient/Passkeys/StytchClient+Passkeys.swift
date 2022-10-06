import AuthenticationServices

extension StytchClient {
    @available(macOS 12.0, iOS 16.0, *)
    public struct Passkeys {
        let router: NetworkingRouter<PasskeysRoute>

        // If we use webauthn current web-backend implementation, this will only be allowed as a secondary factor, and mfa will be required
        public func register(parameters: RegisterParameters) async throws -> AuthenticateResponseType {
            let challenge = try await Server.registerPasskeysStart() // TODO: - find out where to get this

            let startResp: Response<RegisterStartResponseData> = try await router.post(
                to: .registerStart,
                parameters: parameters
            )

            let platformProvider: ASAuthorizationPlatformPublicKeyCredentialProvider = .init(relyingPartyIdentifier: parameters.domain)

            let request = platformProvider.createCredentialRegistrationRequest(
                challenge: challenge, // FIXME: - need to get challenge from server
                name: parameters.name, // we probably want to enforce this to be an email or phone number (if acct exists, must also be in active session during registration)
                userID: .init(startResp.userId.utf8) // this currently relies on session auth, so isn't a pending user id
            )
            let controller = ASAuthorizationController(authorizationRequests: [request])
            let delegate = AuthDelegate()
            controller.delegate = delegate
//            controller.presentationContextProvider = parameters.presentationContextProvider // TODO: pass this in as optional param

            let jsonCredential: Data = try await withCheckedThrowingContinuation { continuation in
                delegate.continuation = continuation
                controller.performRequests()
            }

            return try await router.post(
                to: .register,
                parameters: jsonCredential
            ) as AuthenticateResponse
        }

        public func authenticate(parameters: AuthenticateParameters) async throws -> AuthenticateResponseType {
            let challenge = try await Server.registerPasskeysStart() // FIXME: need to call authenticate start

            let platformProvider: ASAuthorizationPlatformPublicKeyCredentialProvider = .init(relyingPartyIdentifier: parameters.domain)

            let request = platformProvider.createCredentialAssertionRequest(challenge: challenge)

            let controller = ASAuthorizationController(authorizationRequests: [request])
            let delegate = AuthDelegate()
            controller.delegate = delegate

            let jsonCredential: Data = try await withCheckedThrowingContinuation { continuation in
                delegate.continuation = continuation
                controller.performRequests()
            }

            return try await router.post(
                to: .authenticate,
                parameters: jsonCredential
            ) as AuthenticateResponse
        }

        public struct RegisterParameters: Encodable {
            let domain: String
            let name: String
            let authenticatorType = "platform"
        }

        struct RegisterStartResponseData: Decodable {
            let userId: String
            let publicKeyCredentialCreationOptions: String
        }

        public struct AuthenticateParameters {
            let domain: String
        }
    }
}

extension StytchClient {
    @available(macOS 12.0, iOS 16.0, *)
    public static var passkeys: Passkeys {
        .init(router: router.scopedRouter(BaseRoute.passkeys))
    }
}

struct Server {
    // TOOD: - try to get this stuff from webauthn
    static func registerPasskeysStart() async throws -> Data {
        try (
            Current.cryptoClient.dataWithRandomBytesOfCount(32)
        )
    }
}

@available(macOS 12.0, iOS 16.0, *)
final class AuthDelegate: NSObject, ASAuthorizationControllerDelegate {
    var continuation: CheckedContinuation<Data, Error>?

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        switch authorization.credential {
        case let credential as ASAuthorizationPlatformPublicKeyCredentialRegistration:
            continuation?.resume(returning: credential.rawClientDataJSON)
//            credential.rawAttestationObject
            // TODO: should this be returning the rawAttestation?
        case let credential as ASAuthorizationPlatformPublicKeyCredentialAssertion:
            continuation?.resume(returning: credential.rawClientDataJSON)
        default:
            continuation?.resume(throwing: StytchError.randomNumberGenerationFailed) // FIXME: fix error
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        continuation?.resume(throwing: error)
    }
}

enum PasskeysRoute: String, RouteType {
    case register
    case registerStart = "register/start"
    case authenticate
    case authenticateStart = "autenticate/start"

    var path: Path {
        .init(rawValue: rawValue)
    }
}
