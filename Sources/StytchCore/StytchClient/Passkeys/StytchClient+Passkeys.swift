import Foundation

#if !os(watchOS)
public extension StytchClient {
    /// Passkeys are an extremely simple authentication mechanism which securely syncs key sets across your devices — access-controlled via FaceID/TouchID — ultimately enabling WebAuthN-powered public-key authentication with Stytch's servers.
    ///
    /// ## Important Notes
    /// - This initial implementation can only be used for second-factor authentication. A user must already be authenticated via another Stytch factor prior to calling these methods.
    /// - To use Passkey authentication, you must set `NSFaceIDUsageDescription` in your app's `Info.plist`.
    @available(macOS 12.0, iOS 16.0, tvOS 16.0, *)
    // sourcery: ExcludeWatchOS
    struct Passkeys {
        let router: NetworkingRouter<PasskeysRoute>

        @Dependency(\.passkeysClient) private var passkeysClient

        // If we use webauthn current web-backend implementation, this will only be allowed as a secondary factor, and mfa will be required
        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Registers a passkey with the device and with Stytch's servers for the authenticated user.
        public func register(parameters: RegisterParameters) async throws -> BasicResponse {
            let startResp: Response<RegisterStartResponseData> = try await router.post(
                to: .registerStart,
                parameters: parameters
            )

            let credential = try await passkeysClient.registerCredential(
                domain: parameters.domain,
                challenge: startResp.challenge,
                username: String(), // TODO: get email/phone number
                userId: startResp.userId
            )

            guard let attestationObject = credential.rawAttestationObject else { throw StytchError.passkeysMissingAttestationObject }

            let response: BasicResponse = try await router.post(
                to: .register,
                parameters: Credential<AttestationResponse>(
                    id: credential.credentialID,
                    rawId: credential.credentialID,
                    response: .init(
                        clientDataJSON: credential.rawClientDataJSON,
                        attestationObject: attestationObject
                    )
                ).wrapped()
            )
            return response
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Provides second-factor authentication for the authenticated-user via an existing passkey.
        public func authenticate(parameters: AuthenticateParameters) async throws -> AuthenticateResponse {
            let startResp: Response<AuthenticateStartResponseData> = try await router.post(
                to: .authenticateStart,
                parameters: parameters
            )

            let credential = try await passkeysClient.assertCredential(
                domain: parameters.domain,
                challenge: startResp.challenge
            )

            return try await router.post(
                to: .authenticate,
                parameters: Credential<AssertionResponse>(
                    id: credential.credentialID,
                    rawId: credential.credentialID,
                    response: .init(
                        clientDataJSON: credential.rawClientDataJSON,
                        authenticatorData: credential.rawAuthenticatorData,
                        signature: credential.signature,
                        userHandle: credential.userID
                    )
                ).wrapped()
            )
        }
    }
}

public extension StytchClient {
    @available(macOS 12.0, iOS 16.0, tvOS 16.0, *)
    /// The interface for interacting with passkeys products.
    static var passkeys: Passkeys {
        .init(router: router.scopedRouter { $0.passkeys })
    }
}

@available(macOS 12.0, iOS 16.0, tvOS 16.0, *)
public extension StytchClient.Passkeys {
    /// A dedicated parameters type for passkeys `register` calls.
    struct RegisterParameters: Encodable {
        let userId: User.ID
        let domain: String
        let userAgent: String?

        /// - Parameters:
        ///   - userId: The user id associated with your passkey registration.
        ///   - domain: The domain for which your passkey is to be registered.
        ///   - userAgent: The user agent associated with your passkey registration.
        public init(userId: User.ID, domain: String, userAgent: String? = nil) {
            self.userId = userId
            self.domain = domain
            self.userAgent = userAgent
        }
    }

    /// A dedicated parameters type for passkeys `authenticate` calls.
    struct AuthenticateParameters: Encodable {
        let domain: String

        /// - Parameters:
        ///   - domain: The domain for which your passkey is to be registered.
        ///   - sessionDuration: The duration, in minutes, of the requested session. Defaults to 30 minutes.
        ///   - requestBehavior: The  desired behavior of the authentication request. Defaults to a value specific for the platform `RequestBehavior.defaultPlatformValue`
        public init(
            domain: String
        ) {
            self.domain = domain
        }
    }
}

@available(macOS 12.0, iOS 16.0, tvOS 16.0, *)
extension StytchClient.Passkeys {
    struct StartParameters: Encodable {
        let domain: String
    }

    private struct CredentialOptions: Codable {
        enum CodingKeys: CodingKey {
            case challenge
        }

        let challenge: Data

        init(challenge: Data) {
            self.challenge = challenge
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let challengeString: String = try container.decode(key: .challenge)

            guard let challenge: Data = .init(base64UrlEncoded: challengeString) else {
                throw DecodingError.dataCorruptedError(forKey: .challenge, in: container, debugDescription: "challenge not bse64 url encoded")
            }

            self.challenge = challenge
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(challenge.base64UrlEncoded(), forKey: .challenge)
        }
    }

    struct RegisterStartResponseData: Codable {
        private enum CodingKeys: CodingKey {
            case userId
            case publicKeyCredentialCreationOptions
        }

        let userId: User.ID
        let challenge: Data

        init(userId: User.ID, challenge: Data) {
            self.userId = userId
            self.challenge = challenge
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            userId = try container.decode(key: .userId)
            let optionsString: String = try container.decode(key: .publicKeyCredentialCreationOptions)
            let options = try JSONDecoder().decode(CredentialOptions.self, from: Data(optionsString.utf8))
            challenge = options.challenge
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(userId, forKey: .userId)
            let credentialOptions = try JSONEncoder().encode(CredentialOptions(challenge: challenge))
            try container.encode(String(data: credentialOptions, encoding: .utf8), forKey: .publicKeyCredentialCreationOptions)
        }
    }

    struct AuthenticateStartResponseData: Codable {
        private enum CodingKeys: CodingKey {
            case userId
            case publicKeyCredentialRequestOptions
        }

        let userId: User.ID
        let challenge: Data

        init(userId: User.ID, challenge: Data) {
            self.userId = userId
            self.challenge = challenge
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            userId = try container.decode(key: .userId)
            let optionsString: String = try container.decode(key: .publicKeyCredentialRequestOptions)
            let options = try JSONDecoder().decode(CredentialOptions.self, from: Data(optionsString.utf8))
            challenge = options.challenge
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(userId, forKey: .userId)
            let credentialOptions = try JSONEncoder().encode(CredentialOptions(challenge: challenge))
            try container.encode(String(data: credentialOptions, encoding: .utf8), forKey: .publicKeyCredentialRequestOptions)
        }
    }
}

@available(macOS 12.0, iOS 16.0, tvOS 16.0, *)
private extension StytchClient.Passkeys {
    struct Credential<Response: CredentialResponse>: Encodable {
        private enum CodingKeys: CodingKey {
            case type
            case id
            case rawId
            case response
        }

        let type: String = "public-key"
        let id: Data
        let rawId: Data
        let response: Response

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            try container.encode(id.base64UrlEncoded(), forKey: .id)
            try container.encode(rawId.base64UrlEncoded(), forKey: .rawId)
            try container.encode(response, forKey: .response)
        }

        func wrapped(sessionDuration: Minutes? = nil) throws -> CredentialContainer {
            .init(publicKeyCredential: try asJson(encoder: .init()), sessionDurationMinutes: sessionDuration)
        }

        struct CredentialContainer: Encodable {
            let publicKeyCredential: String
            let sessionDurationMinutes: Minutes?
        }
    }

    struct AttestationResponse: CredentialResponse {
        let clientDataJSON: Data
        let attestationObject: Data

        private enum CodingKeys: CodingKey {
            case clientDataJSON
            case attestationObject
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(clientDataJSON.base64UrlEncoded(), forKey: .clientDataJSON)
            try container.encode(attestationObject.base64UrlEncoded(), forKey: .attestationObject)
        }
    }

    struct AssertionResponse: CredentialResponse {
        let clientDataJSON: Data
        let authenticatorData: Data
        let signature: Data
        let userHandle: Data

        private enum CodingKeys: CodingKey {
            case clientDataJSON
            case authenticatorData
            case signature
            case userHandle
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(clientDataJSON.base64UrlEncoded(), forKey: .clientDataJSON)
            try container.encode(authenticatorData.base64UrlEncoded(), forKey: .authenticatorData)
            try container.encode(signature.base64UrlEncoded(), forKey: .signature)
            try container.encode(userHandle.base64UrlEncoded(), forKey: .userHandle)
        }
    }
}

private protocol CredentialResponse: Encodable {}
#endif
