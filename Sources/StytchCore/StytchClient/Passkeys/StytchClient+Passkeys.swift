import Foundation

#if !os(watchOS)
public extension StytchClient {
    @available(macOS 12.0, iOS 16.0, tvOS 16.0, *)
    // sourcery: ExcludeWatchOS
    struct Passkeys {
        let router: NetworkingRouter<PasskeysRoute>

        // If we use webauthn current web-backend implementation, this will only be allowed as a secondary factor, and mfa will be required
        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        public func register(parameters: RegisterParameters) async throws -> BasicResponse {
            let startResp: Response<RegisterStartResponseData> = try await router.post(
                to: .registerStart,
                parameters: parameters
            )

            let credential = try await Current.passkeysClient.registerCredential(
                domain: parameters.domain,
                challenge: startResp.challenge,
                username: parameters.username,
                userId: startResp.userId
            )

            guard let attestationObject = credential.rawAttestationObject else { throw StytchError.oauthCredentialInvalid } // FIXME: - fix error

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
        public func authenticate(parameters: AuthenticateParameters) async throws -> AuthenticateResponseType {
            let startResp: Response<AuthenticateStartResponseData> = try await router.post(
                to: .authenticateStart,
                parameters: StartParameters(domain: parameters.domain)
            )

            let credential = try await Current.passkeysClient.assertCredential(
                domain: parameters.domain,
                challenge: startResp.challenge,
                requestBehavior: parameters.requestBehavior
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
                ).wrapped(sessionDuration: parameters.sessionDuration)
            ) as AuthenticateResponse
        }
    }
}

public extension StytchClient {
    @available(macOS 12.0, iOS 16.0, tvOS 16.0, *)
    static var passkeys: Passkeys {
        .init(router: router.scopedRouter(BaseRoute.passkeys))
    }
}

@available(macOS 12.0, iOS 16.0, tvOS 16.0, *)
public extension StytchClient.Passkeys {
    struct RegisterParameters: Encodable {
        let domain: String
        let username: String

        public init(domain: String, username: String) {
            self.domain = domain
            self.username = username
        }
    }

    struct AuthenticateParameters {
        // swiftlint:disable duplicate_enum_cases
        public enum RequestBehavior {
            #if os(iOS)
            case `default`(preferLocalCredentials: Bool)
            case autoFill
            #else
            case `default`
            #endif

            #if os(iOS)
            public static let defaultPlatformValue: RequestBehavior = .default(preferLocalCredentials: false)
            #else
            public static let defaultPlatformValue: RequestBehavior = .default
            #endif
        }

        // swiftlint:enable duplicate_enum_cases

        let domain: String
        let sessionDuration: Minutes
        let requestBehavior: RequestBehavior

        public init(
            domain: String,
            sessionDuration: Minutes = .defaultSessionDuration,
            requestBehavior: RequestBehavior = .defaultPlatformValue
        ) {
            self.domain = domain
            self.sessionDuration = sessionDuration
            self.requestBehavior = requestBehavior
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

        let userId: String
        let challenge: Data

        init(userId: String, challenge: Data) {
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

        let userId: String
        let challenge: Data

        init(userId: String, challenge: Data) {
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

        func wrapped(sessionDuration: Minutes? = nil) throws -> CredentialWrapper {
            guard let credential = String(data: try JSONEncoder().encode(self), encoding: .utf8) else { throw StytchError.oauthCredentialInvalid } // FIXME: error
            return CredentialWrapper(publicKeyCredential: credential, sessionDurationMinutes: sessionDuration)
        }

        struct CredentialWrapper: Encodable {
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
