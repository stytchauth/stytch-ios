// swiftlint:disable file_length
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
        @Dependency(\.sessionManager) private var sessionManager

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
                username: startResp.user.displayName,
                userId: startResp.userId
            )

            guard let attestationObject = credential.rawAttestationObject else { throw StytchSDKError.missingAttestationObject }

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
            let destination: PasskeysRoute
            if sessionManager.hasValidSessionToken {
                destination = .authenticateStartSecondary
            } else {
                destination = .authenticateStartPrimary
            }
            let startResp: Response<AuthenticateStartResponseData> = try await router.post(
                to: destination,
                parameters: StartParameters(domain: parameters.domain)
            )

            let credential = try await passkeysClient.assertCredential(
                domain: parameters.domain,
                challenge: startResp.challenge,
                requestBehavior: parameters.requestBehavior
            )

            let authenticateResponse: AuthenticateResponse = try await router.post(
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
                ).wrapped(sessionDurationMinutes: parameters.sessionDurationMinutes),
                useDFPPA: true
            )

            sessionManager.consumerLastAuthMethodUsed = .passkeys

            return authenticateResponse
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Updates an existing passkey based on its ID
        public func update(parameters: UpdateParameters) async throws -> PasskeysUpdateResponse {
            try await router.put(
                to: .update(id: parameters.id),
                parameters: PasskeysUpdateRequest(name: parameters.name)
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
    struct RegisterParameters: Encodable, Sendable {
        let domain: String
        let returnPasskeyCredentialOptions: Bool = true

        /// - Parameters:
        ///   - domain: The domain for which your passkey is to be registered.
        public init(domain: String) {
            self.domain = domain
        }
    }

    /// A dedicated parameters type for passkeys `authenticate` calls.
    struct AuthenticateParameters: Sendable {
        /// A type representing the desired request behavior
        public enum RequestBehavior: Sendable {
            #if os(iOS)
            /// Uses the default request behavior with a boolean flag to determine whether credentials are limited to those local on device or whether a passkey on a nearby device can be used
            case `default`(preferLocalCredentials: Bool)
            /// When a user selects a textfield with the `.username` textContentType, an existing local passkey will be suggested to the user.
            case autoFill
            #else
            /// Uses the default request behavior
            case `default`
            #endif

            #if os(iOS)
            /// The RequestBehavior parameter's default value for this platform — `.default(prefersLocalCredentials: false)`
            public static let defaultPlatformValue: RequestBehavior = .default(preferLocalCredentials: false)
            #else
            /// The RequestBehavior parameter's default value for this platform — `.default`
            public static let defaultPlatformValue: RequestBehavior = .default
            #endif
        }

        let domain: String
        let sessionDurationMinutes: Minutes
        let returnPasskeyCredentialOptions: Bool = true
        let requestBehavior: RequestBehavior

        /// - Parameters:
        ///   - domain: The domain for which your passkey is to be registered.
        ///   - sessionDurationMinutes: The duration, in minutes, of the requested session. Defaults to 5 minutes.
        public init(
            domain: String,
            requestBehavior: RequestBehavior = .defaultPlatformValue,
            sessionDurationMinutes: Minutes = StytchClient.defaultSessionDuration
        ) {
            self.domain = domain
            self.sessionDurationMinutes = sessionDurationMinutes
            self.requestBehavior = requestBehavior
        }
    }

    /// A dedicated parameters type for passkeys `update` calls.
    struct UpdateParameters: Encodable, Sendable {
        let id: User.WebAuthNRegistration.ID
        let name: String
        /// - Parameters:
        ///     - id: The id of the Passkey registration to be updated
        ///     - name: The name to update the Passkey registration to
        public init(id: User.WebAuthNRegistration.ID, name: String) {
            self.id = id
            self.name = name
        }
    }
}

@available(macOS 12.0, iOS 16.0, tvOS 16.0, *)
extension StytchClient.Passkeys {
    struct StartParameters: Encodable, Sendable {
        let domain: String
        let returnPasskeyCredentialOptions: Bool = true
    }

    struct PasskeysUser: Codable, Sendable {
        let displayName: String
    }

    private struct CredentialCreationOptions: Codable, Sendable {
        enum CodingKeys: CodingKey {
            case challenge
            case user
        }

        let challenge: Data
        let user: PasskeysUser

        init(challenge: Data, user: PasskeysUser) {
            self.challenge = challenge
            self.user = user
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let challengeString: String = try container.decode(key: .challenge)
            let user: PasskeysUser = try container.decode(key: .user)
            self.user = user

            guard let challenge: Data = .init(base64UrlEncoded: challengeString) else {
                throw DecodingError.dataCorruptedError(forKey: .challenge, in: container, debugDescription: "challenge not base64 url encoded")
            }

            self.challenge = challenge
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(challenge.base64UrlEncoded(), forKey: .challenge)
            try container.encode(user, forKey: .user)
        }
    }

    private struct CredentialOptions: Codable, Sendable {
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
                throw DecodingError.dataCorruptedError(forKey: .challenge, in: container, debugDescription: "challenge not base64 url encoded")
            }

            self.challenge = challenge
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(challenge.base64UrlEncoded(), forKey: .challenge)
        }
    }

    struct RegisterStartResponseData: Codable, Sendable {
        private enum CodingKeys: CodingKey {
            case userId
            case publicKeyCredentialCreationOptions
        }

        let userId: User.ID
        let challenge: Data
        let user: PasskeysUser

        init(userId: User.ID, challenge: Data, user: PasskeysUser) {
            self.userId = userId
            self.challenge = challenge
            self.user = user
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            userId = try container.decode(key: .userId)
            let optionsString: String = try container.decode(key: .publicKeyCredentialCreationOptions)
            let options = try JSONDecoder().decode(CredentialCreationOptions.self, from: Data(optionsString.utf8))
            challenge = options.challenge
            user = options.user
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(userId, forKey: .userId)
            let credentialOptions = try JSONEncoder().encode(CredentialCreationOptions(challenge: challenge, user: user))
            try container.encode(String(data: credentialOptions, encoding: .utf8), forKey: .publicKeyCredentialCreationOptions)
        }
    }

    struct AuthenticateStartResponseData: Codable, Sendable {
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

public struct PasskeysUpdateResponseData: Codable, Sendable {
    private enum CodingKeys: CodingKey {
        case webauthnRegistrationId
    }

    let webauthnRegistrationId: User.WebAuthNRegistration.ID

    init(webauthnRegistrationId: User.WebAuthNRegistration.ID) {
        self.webauthnRegistrationId = webauthnRegistrationId
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        webauthnRegistrationId = try container.decode(key: .webauthnRegistrationId)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(webauthnRegistrationId, forKey: .webauthnRegistrationId)
    }
}

public struct PasskeysUpdateRequest: Codable, Sendable {
    private enum CodingKeys: CodingKey {
        case name
    }

    let name: String

    // swiftlint:disable:next unneeded_synthesized_initializer
    init(name: String) {
        self.name = name
    }
}

public typealias PasskeysUpdateResponse = Response<PasskeysUpdateResponseData>

@available(macOS 12.0, iOS 16.0, tvOS 16.0, *)
private extension StytchClient.Passkeys {
    struct Credential<Response: CredentialResponse & Sendable>: Encodable, Sendable {
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

        func wrapped(sessionDurationMinutes: Minutes? = nil) throws -> CredentialContainer {
            .init(publicKeyCredential: try asJson(encoder: .init()), sessionDurationMinutes: sessionDurationMinutes)
        }

        struct CredentialContainer: Encodable {
            let publicKeyCredential: String
            let sessionDurationMinutes: Minutes?
        }
    }

    struct AttestationResponse: CredentialResponse, Sendable {
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

    struct AssertionResponse: CredentialResponse, Sendable {
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

private protocol CredentialResponse: Encodable, Sendable {}
#endif
