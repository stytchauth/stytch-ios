import Foundation

#if !os(tvOS) && !os(watchOS)
import LocalAuthentication
public extension StytchClient.Biometrics {
    enum Availability {
        case systemUnavailable(LAError.Code?)
        case availableNoRegistration
        case availableRegistered

        public var isSystemUnavailable: Bool {
            if case .systemUnavailable = self { return true }
            return false
        }

        public var isAvailableNoRegistration: Bool {
            if case .availableNoRegistration = self { return true }
            return false
        }

        public var isAvailableRegistered: Bool {
            if case .availableRegistered = self { return true }
            return false
        }
    }
}

public extension StytchClient {
    /// The interface for interacting with biometrics products.
    static var biometrics: Biometrics { .init(router: router.scopedRouter { $0.biometrics }) }
}

public extension StytchClient {
    // sourcery: ExcludeWatchAndTVOS
    /// Biometric authentication enables your users to leverage their devices' built-in biometric authenticators such as FaceID and TouchID for quick and seamless login experiences.
    ///
    /// ## Important Notes
    /// - To use Biometric authentication, you must set `NSFaceIDUsageDescription` in your app's `Info.plist`.
    struct Biometrics {
        let router: NetworkingRouter<BiometricsRoute>

        @Dependency(\.cryptoClient) private var cryptoClient

        @Dependency(\.keychainClient) private var keychainClient

        @Dependency(\.userDefaultsClient) private var userDefaultsClient

        @Dependency(\.sessionManager) private var sessionManager

        @Dependency(\.jsonDecoder) private var jsonDecoder

        /// Indicates if there is an existing biometric registration on device.
        public var registrationAvailable: Bool {
            keychainClient.valueExistsForItem(item: .privateKeyRegistration)
        }

        public var biometricRegistrationId: String? {
            try? userDefaultsClient.getStringValue(.biometricKeyRegistration)
        }

        /// Indicates if biometrics are available
        public var availability: Availability {
            var error: NSError?
            switch (LocalAuthenticationContextManager.localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error), registrationAvailable) {
            case (false, _):
                return .systemUnavailable((error as? LAError)?.code)
            case (true, false):
                return .availableNoRegistration
            case (true, true):
                return .availableRegistered
            }
        }

        /// Returns the type of biometric authentication available on the device. touchID or faceID
        public var biometryType: LABiometryType {
            _ = LocalAuthenticationContextManager.localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            return LocalAuthenticationContextManager.localAuthenticationContext.biometryType
        }

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

            LocalAuthenticationContextManager.updateLaContextStrings(strings: parameters.promptStrings)

            guard LocalAuthenticationContextManager.localAuthenticationContext.canEvaluatePolicy(parameters.accessPolicy, error: nil) else {
                throw StytchSDKError.biometricsUnavailable
            }

            if parameters.shouldEvaluatePolicyOnRegister == true {
                guard try await LocalAuthenticationContextManager.localAuthenticationContext.evaluatePolicy(parameters.accessPolicy, localizedReason: parameters.promptStrings.localizedReason) else {
                    throw StytchSDKError.biometricAuthenticationFailed
                }
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
                    sessionDurationMinutes: parameters.sessionDurationMinutes
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
            try userDefaultsClient.setStringValue(registration.registrationId.rawValue, for: .biometricKeyRegistration)

            return finishResponse
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// If a valid biometric registration exists, this method confirms the current device owner via the device's built-in biometric reader and returns an updated session object by either starting a new session or adding a the biometric factor to an existing session.
        public func authenticate(parameters: AuthenticateParameters) async throws -> AuthenticateResponse {
            guard let privateKeyRegistrationQueryResult: KeychainQueryResult = try keychainClient.getQueryResults(item: .privateKeyRegistration).first else {
                throw StytchSDKError.noBiometricRegistration
            }

            LocalAuthenticationContextManager.updateLaContextStrings(strings: parameters.promptStrings)

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
                sessionDurationMinutes: parameters.sessionDurationMinutes
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
            let biometricKeyRegistrationQueryResult = try? userDefaultsClient.getItem(item: .biometricKeyRegistration)
            if biometricKeyRegistrationQueryResult == nil, let privateKeyRegistration = try privateKeyRegistrationQueryResult.generic.map({ try jsonDecoder.decode(BiometricPrivateKeyRegistration.self, from: $0) }) {
                try userDefaultsClient.setStringValue(privateKeyRegistration.registrationId.rawValue, for: .biometricKeyRegistration)
            }
        }
    }
}

public extension StytchClient.Biometrics {
    typealias RegisterCompleteResponse = Response<RegisterCompleteResponseData>

    /// A dedicated parameters type for biometrics `authenticate` calls.
    struct AuthenticateParameters: Sendable {
        let sessionDurationMinutes: Minutes
        let promptStrings: LAContextPromptStrings

        /// Initializes the parameters struct
        /// - Parameters:
        ///   - sessionDurationMinutes: The duration, in minutes, for the requested session. Defaults to 5 minutes.
        ///   - promptStrings: The localized prompt strings for an `LAContext`.
        public init(
            sessionDurationMinutes: Minutes = StytchClient.defaultSessionDuration,
            promptStrings: LAContextPromptStrings = .defaultPromptStrings
        ) {
            self.sessionDurationMinutes = sessionDurationMinutes
            self.promptStrings = promptStrings
        }
    }

    /// A dedicated parameters type for biometrics `register` calls.
    struct RegisterParameters: Sendable {
        let identifier: String
        let accessPolicy: LAPolicy
        let sessionDurationMinutes: Minutes
        let promptStrings: LAContextPromptStrings
        let shouldEvaluatePolicyOnRegister: Bool

        /// Initializes the parameters struct
        /// - Parameters:
        ///   - identifier: An id used to easily identify the account associated with the biometric registration, generally an email or phone number.
        ///   - accessPolicy: Defines the policy as to how the user must confirm their ownership.
        ///   - sessionDurationMinutes: The duration, in minutes, for the requested session. Defaults to 5 minutes.
        ///   - promptStrings: The localized prompt strings for an `LAContext`.
        ///   - shouldEvaluatePolicyOnRegister: Indicates whether the biometric policy should be evaluated when registering.
        ///     For example, if this is true you will see the Face ID prompt during registration.
        ///     It is not explicitly necessary to show Face ID on register, because the private key for biometric authentication can be written to the keychain without showing a biometric prompt,
        ///     with the stipulation that reading the private key from the keychain will require evaluating a biometric policy.
        ///     You can optionally show the prompt if it makes sense for your flow.
        public init(
            identifier: String,
            accessPolicy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics,
            sessionDurationMinutes: Minutes = StytchClient.defaultSessionDuration,
            promptStrings: LAContextPromptStrings = .defaultPromptStrings,
            shouldEvaluatePolicyOnRegister: Bool = true
        ) {
            self.identifier = identifier
            self.accessPolicy = accessPolicy
            self.sessionDurationMinutes = sessionDurationMinutes
            self.promptStrings = promptStrings
            self.shouldEvaluatePolicyOnRegister = shouldEvaluatePolicyOnRegister
        }
    }

    struct RegisterCompleteResponseData: Codable, Sendable, AuthenticateResponseDataType {
        public let biometricRegistrationId: User.BiometricRegistration.ID
        public let user: User
        public let session: Session
        public let sessionToken: String
        public let sessionJwt: String
        public let userDevice: DeviceHistory?
    }
}

extension LAPolicy {
    var keychainValue: KeychainItem.AccessPolicy {
        switch self {
        case .deviceOwnerAuthentication:
            return .deviceOwnerAuthentication
        case .deviceOwnerAuthenticationWithBiometrics, .deviceOwnerAuthenticationWithCompanion, .deviceOwnerAuthenticationWithBiometricsOrCompanion:
            return .deviceOwnerAuthenticationWithBiometrics
        #if os(macOS)
        case .deviceOwnerAuthenticationWithBiometricsOrWatch:
            return .deviceOwnerAuthenticationWithBiometricsOrWatch
        #endif
        @unknown default:
            return .deviceOwnerAuthenticationWithBiometrics
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
        let biometricRegistrationId: User.BiometricRegistration.ID
        let signature: Data
        let sessionDurationMinutes: Minutes
    }
}

#endif
