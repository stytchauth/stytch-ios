import Foundation

public extension StytchClient {
    /// Biometric authentication enables your users to leverage their devices' built-in biometric authenticators such as FaceID and TouchID for quick and seamless login experiences.
    struct Biometrics {
        let router: NetworkingRouter<BiometricsRoute>

        /// Indicates if there is an existing biometric registration on device.
        public var registrationAvailable: Bool {
            Current.defaults.bool(forKey: Self.biometricRegistrationDefaultsKey)
        }

        /// Clears existing biometric registrations stored on device. Useful when removing a user from a given device.
        public func removeRegistration() throws {
            try Current.keychainClient.removeItem(.privateKeyRegistration)
            Current.defaults.removeObject(forKey: Self.biometricRegistrationDefaultsKey)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// When a valid/active session exists, this method will add a biometric registration for the current user. The user will later be able to start a new session with biometrics or use biometrics as an additional authentication factor.
        ///
        /// NOTE: - You should ensure the `accessPolicy` parameters match your particular needs, defaults to `deviceOwnerWithBiometrics`.
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

            Current.defaults.set(true, forKey: Self.biometricRegistrationDefaultsKey)

            return finishResponse
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// If a valid biometric registration exists, this method confirms the current device owner via the device's built-in biometric reader and returns an updated session object by either starting a new session or adding a the biometric factor to an existing session.
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

            // NOTE: - We could return separate concrete type which deserializes/contains biometric_registration_id, but this doesn't currently add much value
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
    /// A dedicated parameters type for biometrics `authenticate` calls.
    struct AuthenticateParameters {
        let sessionDuration: Minutes

        /// Initializes the parameters struct
        /// - Parameter sessionDuration: The duration, in minutes, for the requested session. Defaults to 30 minutes.
        public init(sessionDuration: Minutes = .defaultSessionDuration) {
            self.sessionDuration = sessionDuration
        }
    }

    /// A dedicated parameters type for biometrics `register` calls.
    struct RegisterParameters {
        let identifier: String
        let accessPolicy: AccessPolicy
        let sessionDuration: Minutes

        /// Initializes the parameters struct
        /// - Parameters:
        ///   - identifier: An id used to easily identify the account associated with the biometric registration, generally an email or phone number.
        ///   - accessPolicy: Defines the policy as to how the user must confirm their ownership.
        ///   - sessionDuration: The duration, in minutes, for the requested session. Defaults to 30 minutes.
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
    /// Defines the policy as to how the user must confirm their device ownership.
    enum AccessPolicy {
        /// The device will first try to confirm access rights via biometrics and will fall back to device passcode.
        case deviceOwnerAuthentication
        /// The device will try to confirm access rights via biometrics.
        case deviceOwnerAuthenticationWithBiometrics
        #if os(macOS)
        /// The device will, in parallel, try to confirm access rights via biometrics or an associated Apple Watch.
        case deviceOwnerAuthenticationWithBiometricsOrWatch // swiftlint:disable:this identifier_name
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
    private static let biometricRegistrationDefaultsKey: String = "biometric_registration_available"
}

// Internal/private parameters and keys
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

    struct RegisterCompleteResponseData: Codable, AuthenticateResponseDataType {
        let biometricRegistrationId: String
        let user: User
        let session: Session
        let sessionToken: String
        let sessionJwt: String
    }
}
