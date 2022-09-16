import Foundation

public extension StytchClient {
    /// some docs
    struct Biometrics {
        let router: NetworkingRouter<BiometricsRoute>

        private static let biometricRegistrationKey: String = "biometric_registration_available"

        public var registrationAvailable: Bool {
            Current.defaults.bool(forKey: Self.biometricRegistrationKey)
        }

        public func removeRegistration() throws {
            try Current.keychainClient.removeItem(.privateKeyRegistration)
            Current.defaults.removeObject(forKey: Self.biometricRegistrationKey)
        }

        // sourcery: AsyncAsyncVariants, (NOTE: - must use /// doc comment styling)
        /// some docs
        public func register(parameters: RegisterParameters) async throws -> AuthenticateResponseType {
            // Early out if not authenticated
            guard (Current.sessionStorage.sessionToken ?? Current.sessionStorage.sessionJwt) != nil else {
                throw StytchError.noCurrentSession
            }

            let (privateKey, publicKey) = Current.cryptoClient.generateKeyPair()

            let startResponse: RegisterStartResponse = try await router.post(
                to: .register(.start),
                parameters: RegisterStartParameters(publicKey: publicKey)
            )

            let finishResponse: Response<RegisterCompleteResponseData> = try await router.post(
                to: .register(.complete),
                parameters: RegisterFinishParameters(
                    biometricRegistrationId: startResponse.biometricRegistrationId,
                    signature: Current.cryptoClient.signChallengeWithPrivateKey(
                        startResponse.challenge,
                        privateKey
                    ),
                    sessionDuration: parameters.sessionDuration
                )
            )

            let registration: KeychainClient.KeyRegistration = .init(
                userId: finishResponse.user.id,
                userLabel: parameters.identifier,
                registrationId: finishResponse.biometricRegistrationId
            )

            try Current.keychainClient.set(
                key: privateKey,
                registration: registration,
                accessPolicy: parameters.accessPolicy.keychainValue
            )

            Current.defaults.set(true, forKey: Self.biometricRegistrationKey)

            return finishResponse
        }

        // sourcery: AsyncAsyncVariants, (NOTE: - must use /// doc comment styling)
        /// some docs
        public func authenticate(parameters: AuthenticateParameters) async throws -> AuthenticateResponseType {
            guard let queryResult: KeychainClient.QueryResult = try Current.keychainClient.get(.privateKeyRegistration).first else {
                throw StytchError.noBiometricRegistrationsAvailable
            }

            let privateKey = queryResult.data
            let publicKey = try Current.cryptoClient.publicKeyForPrivateKey(privateKey)

            let startResponse: AuthenticateStartResponse = try await router.post(
                to: .authenticate(.start),
                parameters: AuthenticateStartParameters(publicKey: publicKey)
            )

            // NOTE: - Could return separate concrete type which deserializes/contains biometric_registration_id, but this doesn't seem to add much value
            return try await router.post(
                to: .authenticate(.complete),
                parameters: AuthenticateCompleteParameters(
                    signature: Current.cryptoClient.signChallengeWithPrivateKey(startResponse.challenge, privateKey),
                    biometricRegistrationId: startResponse.biometricRegistrationId,
                    sessionDurationMinutes: parameters.sessionDuration
                )
            ) as AuthenticateResponse
        }
    }
}

#if !os(tvOS) && !os(watchOS)
public extension StytchClient {
    /// The interface for interacting with biometrics products.
    static var biometrics: Biometrics { .init(router: router.scopedRouter(BaseRoute.biometrics)) }
}
#endif

public extension StytchClient.Biometrics {
    struct AuthenticateParameters {
        let sessionDuration: Minutes

        public init(sessionDuration: Minutes = .defaultSessionDuration) {
            self.sessionDuration = sessionDuration
        }
    }

    struct RegisterParameters {
        // email or phone number
        public let identifier: String
        public let accessPolicy: AccessPolicy
        public let sessionDuration: Minutes

        public init(
            identifier: String,
            accessPolicy: StytchClient.Biometrics.RegisterParameters.AccessPolicy = .deviceOwnerAuthenticationWithBiometrics,
            sessionDuration: Minutes = .defaultSessionDuration
        ) {
            self.identifier = identifier
            self.accessPolicy = accessPolicy
            self.sessionDuration = sessionDuration
        }
    }
}

public extension StytchClient.Biometrics.RegisterParameters {
    enum AccessPolicy {
        case deviceOwnerAuthentication
        case deviceOwnerAuthenticationWithBiometrics
        #if os(macOS)
        // swiftlint:disable:next identifier_name
        case deviceOwnerAuthenticationWithBiometricsOrWatch
        #endif

        var keychainValue: KeychainClient.Item.AccessPolicy {
            switch self {
            case .deviceOwnerAuthentication:
                return .deviceOwnerAuthentication
            case .deviceOwnerAuthenticationWithBiometrics:
                return .deviceOwnerAuthenticationWithBiometrics
            #if os(macOS)
            case .deviceOwnerAuthenticationWithBiometricsOrWatch:
                return .deviceOwnerAuthenticationWithBiometricsOrWatch
            #endif
            }
        }
    }
}

extension StytchClient.Biometrics {
    struct AuthenticateStartParameters: Encodable {
        let publicKey: Data
    }

    struct AuthenticateStartResponse: Codable {
        let challenge: Data
        let biometricRegistrationId: String
    }

    struct AuthenticateCompleteParameters: Codable {
        let signature: Data
        let biometricRegistrationId: String
        let sessionDurationMinutes: Minutes
    }

    private struct RegisterStartParameters: Encodable {
        let publicKey: Data
    }

    struct RegisterStartResponse: Codable {
        let biometricRegistrationId: String
        let challenge: Data
    }

    private struct RegisterFinishParameters: Encodable {
        private enum CodingKeys: String, CodingKey {
            case biometricRegistrationId, signature, sessionDuration = "session_duration_minutes"
        }

        let biometricRegistrationId: String
        let signature: Data
        let sessionDuration: Minutes
    }

    struct RegisterCompleteResponseData: Codable, AuthenticateResponseType {
        let biometricRegistrationId: String
        let user: User
        let session: Session
        let sessionToken: String
        let sessionJwt: String
    }
}
