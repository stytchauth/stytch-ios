import Foundation

#if !os(tvOS) && !os(watchOS)
import LocalAuthentication
public extension StytchClient.Biometrics {
    enum Availability {
        case systemUnavailable(LAError.Code?)
        case availableNoRegistration
        case availableRegistered
    }
}

public extension StytchClient {
    /// The interface for interacting with biometrics products.
    static var biometrics: Biometrics { .init(router: router.scopedRouter { $0.biometrics }) }
}
#endif

public extension StytchClient {
    /// Biometric authentication enables your users to leverage their devices' built-in biometric authenticators such as FaceID and TouchID for quick and seamless login experiences.
    ///
    /// ## Important Notes
    /// - To use Biometric authentication, you must set `NSFaceIDUsageDescription` in your app's `Info.plist`.
    struct Biometrics {
        let router: NetworkingRouter<BiometricsRoute>

        @Dependency(\.cryptoClient) private var cryptoClient

        @Dependency(\.keychainClient) private var keychainClient

        @Dependency(\.sessionManager) private var sessionManager

        @Dependency(\.jsonDecoder) private var jsonDecoder

        /// Indicates if there is an existing biometric registration on device.
        public var registrationAvailable: Bool {
            keychainClient.valueExistsForItem(item: .privateKeyRegistration)
        }

        public var biometricRegistrationId: String? {
            guard let biometricKeyRegistrationQueryResult = try? keychainClient.getQueryResults(item: .biometricKeyRegistration).first else {
                return nil
            }
            return biometricKeyRegistrationQueryResult.stringValue
        }

        #if !os(tvOS) && !os(watchOS)
        /// Indicates if biometrics are available
        public var availability: Availability {
            let context = LAContext()
            var error: NSError?
            switch (context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error), registrationAvailable) {
            case (false, _):
                return .systemUnavailable((error as? LAError)?.code)
            case (true, false):
                return .availableNoRegistration
            case (true, true):
                return .availableRegistered
            }
        }
        #endif

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Removes the current device's existing biometric registration from both the device itself and from the server.
        public func removeRegistration() async throws {
            // If the biometric registration ID exists in the keychain, we can use it to remove the auth factor therefore deleting the registration from backend.
            // This requires authentication with all necessary factors.
            // Otherwise, the API will return an "insufficient_factors" error when calling "deleteFactor".
            guard let biometricRegistrationId = biometricRegistrationId else {
                throw StytchSDKError.noBiometricRegistrationId
            }

            _ = try await StytchClient.user.deleteFactor(.biometricRegistration(id: User.BiometricRegistration.ID(stringLiteral: biometricRegistrationId)))

            // Remove local registrations
            try clearBiometricRegistrations()
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// When a valid/active session exists, this method will add a biometric registration for the current user. The user will later be able to start a new session with biometrics or use biometrics as an additional authentication factor.
        ///
        /// NOTE: - You should ensure the `accessPolicy` parameters match your particular needs, defaults to `deviceOwnerWithBiometrics`.
        public func register(parameters: RegisterParameters) async throws -> RegisterCompleteResponse {
            // Early out if not authenticated
            guard sessionManager.hasValidSessionToken else {
                throw StytchSDKError.noCurrentSession
            }

            // Early return if the user is already enrolled in biometrics
            guard registrationAvailable == false else {
                throw StytchSDKError.biometricsAlreadyEnrolled
            }

            let (privateKey, publicKey) = cryptoClient.generateKeyPair()

            let startResponse: RegisterStartResponse = try await router.post(
                to: .register(.start),
                parameters: RegisterStartParameters(publicKey: publicKey)
            )

            let finishResponse: Response<RegisterCompleteResponseData> = try await router.post(
                to: .register(.complete),
                parameters: RegisterFinishParameters(
                    biometricRegistrationId: startResponse.biometricRegistrationId,
                    signature: cryptoClient.signChallengeWithPrivateKey(
                        startResponse.challenge,
                        privateKey
                    ),
                    sessionDuration: parameters.sessionDuration
                )
            )

            let registration: BiometricPrivateKeyRegistration = .init(
                userId: finishResponse.user.id,
                userLabel: parameters.identifier,
                registrationId: finishResponse.biometricRegistrationId
            )

            // Set the .privateKeyRegistration
            try keychainClient.setPrivateKeyRegistration(
                key: privateKey,
                registration: registration,
                accessPolicy: parameters.accessPolicy.keychainValue
            )

            // Set the .biometricKeyRegistration
            try keychainClient.setStringValue(registration.registrationId.rawValue, for: .biometricKeyRegistration)

            return finishResponse
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// If a valid biometric registration exists, this method confirms the current device owner via the device's built-in biometric reader and returns an updated session object by either starting a new session or adding a the biometric factor to an existing session.
        public func authenticate(parameters: AuthenticateParameters) async throws -> AuthenticateResponse {
            guard let privateKeyRegistrationQueryResult: KeychainQueryResult = try keychainClient.getQueryResults(item: .privateKeyRegistration).first else {
                throw StytchSDKError.noBiometricRegistration
            }

            try copyBiometricRegistrationIDToKeychainIfNeeded(privateKeyRegistrationQueryResult)

            let privateKey = privateKeyRegistrationQueryResult.data
            let publicKey = try cryptoClient.publicKeyForPrivateKey(privateKey)

            let startResponse: AuthenticateStartResponse = try await router.post(
                to: .authenticate(.start),
                parameters: AuthenticateStartParameters(publicKey: publicKey)
            )

            let authenticateCompleteParameters = AuthenticateCompleteParameters(
                signature: try cryptoClient.signChallengeWithPrivateKey(startResponse.challenge, privateKey),
                biometricRegistrationId: startResponse.biometricRegistrationId,
                sessionDurationMinutes: parameters.sessionDuration
            )

            // NOTE: - We could return separate concrete type which deserializes/contains biometric_registration_id, but this doesn't currently add much value
            let authenticateResponse: AuthenticateResponse = try await router.post(
                to: .authenticate(.complete),
                parameters: authenticateCompleteParameters,
                useDFPPA: true
            )

            sessionManager.consumerLastAuthMethodUsed = .biometrics

            return authenticateResponse
        }

        // Clear both the .privateKeyRegistration and the .biometricKeyRegistration
        func clearBiometricRegistrations() throws {
            try keychainClient.removeItem(item: .privateKeyRegistration)
            try keychainClient.removeItem(item: .biometricKeyRegistration)
        }

        // if we have a local biometric registration that doesn't exist on the user object, delete the local
        func cleanupPotentiallyOrphanedBiometricRegistrations() {
            guard let user = StytchClient.user.getSync() else {
                return
            }

            if user.biometricRegistrations.isEmpty {
                try? clearBiometricRegistrations()
            } else {
                // Map the users biometricRegistrations to an array of strings
                var userBiometricRegistrationIds = [String]()
                for biometricRegistration in user.biometricRegistrations {
                    userBiometricRegistrationIds.append(biometricRegistration.biometricRegistrationId.rawValue)
                }

                // Check if the user's biometric registrations contain the ID
                if let biometricRegistrationId = biometricRegistrationId, userBiometricRegistrationIds.contains(biometricRegistrationId) == false {
                    // Remove the orphaned biometric registration
                    try? clearBiometricRegistrations()
                }
            }
        }

        /*
         After introducing the .biometricKeyRegistration keychain item in version 0.54.0, we needed a way for versions prior to 0.54.0
         to copy the value stored in the biometrically protected .privateKeyRegistration keychain item into the non-biometric
         .biometricKeyRegistration keychain item without triggering unnecessary Face ID prompts. Since a Face ID prompt is already
         being shown here for authentication, we decided to use this as an opportunity to perform the migration by copying the
         registration ID into the .biometricKeyRegistration keychain item. For versions after 0.54.0, this action occurs during
         registration, and it should only happen here if the .biometricKeyRegistration keychain item is empty.

         Keeping `biometricKeyRegistration` unprotected by biometrics was essential for performing cleanup and deletion operations
         without prompting the user unnecessarily for biometric authentication.
         */
        func copyBiometricRegistrationIDToKeychainIfNeeded(_ privateKeyRegistrationQueryResult: KeychainQueryResult) throws {
            let biometricKeyRegistrationQueryResult = try? keychainClient.getQueryResults(item: .biometricKeyRegistration).first
            if biometricKeyRegistrationQueryResult == nil, let privateKeyRegistration = try privateKeyRegistrationQueryResult.generic.map({ try jsonDecoder.decode(BiometricPrivateKeyRegistration.self, from: $0) }) {
                try keychainClient.setStringValue(privateKeyRegistration.registrationId.rawValue, for: .biometricKeyRegistration)
            }
        }
    }
}

public extension StytchClient.Biometrics {
    typealias RegisterCompleteResponse = Response<RegisterCompleteResponseData>

    /// A dedicated parameters type for biometrics `authenticate` calls.
    struct AuthenticateParameters: Sendable {
        let sessionDuration: Minutes

        /// Initializes the parameters struct
        /// - Parameter sessionDuration: The duration, in minutes, for the requested session. Defaults to 5 minutes.
        public init(sessionDuration: Minutes = .defaultSessionDuration) {
            self.sessionDuration = sessionDuration
        }
    }

    /// A dedicated parameters type for biometrics `register` calls.
    struct RegisterParameters: Sendable {
        let identifier: String
        let accessPolicy: AccessPolicy
        let sessionDuration: Minutes

        /// Initializes the parameters struct
        /// - Parameters:
        ///   - identifier: An id used to easily identify the account associated with the biometric registration, generally an email or phone number.
        ///   - accessPolicy: Defines the policy as to how the user must confirm their ownership.
        ///   - sessionDuration: The duration, in minutes, for the requested session. Defaults to 5 minutes.
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

    struct RegisterCompleteResponseData: Codable, Sendable, AuthenticateResponseDataType {
        public let biometricRegistrationId: User.BiometricRegistration.ID
        public let user: User
        public let session: Session
        public let sessionToken: String
        public let sessionJwt: String
    }
}

public extension StytchClient.Biometrics.RegisterParameters {
    /// Defines the policy as to how the user must confirm their device ownership.
    enum AccessPolicy: Sendable {
        /// The device will first try to confirm access rights via biometrics and will fall back to device passcode.
        case deviceOwnerAuthentication
        /// The device will try to confirm access rights via biometrics.
        case deviceOwnerAuthenticationWithBiometrics
        #if os(macOS)
        /// The device will, in parallel, try to confirm access rights via biometrics or an associated Apple Watch.
        case deviceOwnerAuthenticationWithBiometricsOrWatch // swiftlint:disable:this identifier_name
        #endif

        var keychainValue: KeychainItem.AccessPolicy {
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

// Internal/private parameters and keys
extension StytchClient.Biometrics {
    struct AuthenticateStartParameters: Encodable, Sendable {
        let publicKey: Data
    }

    struct AuthenticateStartResponse: Codable, Sendable {
        let challenge: Data
        let biometricRegistrationId: User.BiometricRegistration.ID
    }

    struct AuthenticateCompleteParameters: Codable, Sendable {
        let signature: Data
        let biometricRegistrationId: User.BiometricRegistration.ID
        let sessionDurationMinutes: Minutes
    }

    private struct RegisterStartParameters: Encodable, Sendable {
        let publicKey: Data
    }

    struct RegisterStartResponse: Codable, Sendable {
        let biometricRegistrationId: User.BiometricRegistration.ID
        let challenge: Data
    }

    private struct RegisterFinishParameters: Encodable, Sendable {
        private enum CodingKeys: String, CodingKey {
            case biometricRegistrationId, signature, sessionDuration = "sessionDurationMinutes"
        }

        let biometricRegistrationId: User.BiometricRegistration.ID
        let signature: Data
        let sessionDuration: Minutes
    }
}
