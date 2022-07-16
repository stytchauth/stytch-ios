import Foundation

// NOTE: - Ability to import LocalAuthentication serves as a proxy for supported platforms for biometrics
#if canImport(LocalAuthentication)
extension StytchClient {
    /// some docs
    struct Biometrics {
        let pathContext: Endpoint.Path = "biometrics"

        // sourcery: AsyncAsyncVariants, (NOTE: - must use /// doc comment styling)
        /// some docs
        public func register(parameters: RegisterParameters) async throws -> BasicResponse {
            // Early out if not authenticated
            guard (Current.sessionStorage.sessionToken ?? Current.sessionStorage.sessionJwt) != nil else {
                throw StytchError.noCurrentSession
            }

            let (privateKey, publicKey) = Current.cryptoClient.generateKeyPair()

            let pathContext = pathContext.appendingPathComponent("register")

            let startResponse: RegisterStartResponse = try await StytchClient.post(
                to: .init(path: pathContext.appendingPathComponent("start")),
                parameters: RegisterStartParameters(publicKey: publicKey)
            )

            let finishResponse: Response<RegisterFinishResponseData> = try await StytchClient.post(
                to: .init(path: pathContext),
                parameters: RegisterFinishParameters(
                    biometricRegistrationId: startResponse.biometricRegistrationId,
                    signature: Current.cryptoClient.signChallengeWithPrivateKey(
                        startResponse.challenge,
                        privateKey
                    )
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
                accessPolicy: parameters.accessPolicy.keychainValue,
                syncingBehavior: parameters.syncingBehavior.keychainValue
            )

            return .init(
                requestId: finishResponse.requestId,
                statusCode: finishResponse.statusCode
            )
        }

        // sourcery: AsyncAsyncVariants, (NOTE: - must use /// doc comment styling)
        /// some docs
        public func authenticate(
            parameters: AuthenticateParameters,
            handler: ([Registration]) async -> Registration
        ) async throws -> AuthenticateResponse {
            guard case let queryResults = try Current.keychainClient.get(.privateKeyRegistration), !queryResults.isEmpty else {
                throw StytchError.noBiometricRegistrationsAvailable
            }

            let queryResult: KeychainClient.QueryResult

            if let result = queryResults.first, queryResults.count == 1 {
                queryResult = result
            } else {
                let registrations = queryResults.enumerated().compactMap { index, result in
                    result.label.map { Registration(userLabel: $0, createdAt: result.createdAt, index: index) }
                }
                queryResult = await queryResults[handler(registrations).index]
            }
            let privateKey = queryResult.data
            let publicKey = try Current.cryptoClient.publicKeyForPrivateKey(privateKey)

            let pathContext = pathContext.appendingPathComponent("authenticate")

            let startResponse: AuthenticateStartResponse = try await StytchClient.post(
                to: .init(path: pathContext.appendingPathComponent("start")),
                parameters: AuthenticateStartParameters(publicKey: publicKey, userId: queryResult.account)
            )

            // Could use separate concrete type which contains biometric registration id, but this doesn't seem to add value
            return try await StytchClient.post(
                to: .init(path: pathContext),
                parameters: AuthenticateFinishParameters(
                    signature: Current.cryptoClient.signChallengeWithPrivateKey(startResponse.challenge, privateKey),
                    biometricRegistrationId: startResponse.biometricRegistrationId,
                    sessionDurationMinutes: parameters.sessionDuration
                )
            )
        }
    }
}

extension StytchClient {
    /// The interface for interacting with biometrics products.
    static var biometrics: Biometrics { .init() }
}

extension StytchClient.Biometrics {
    struct AuthenticateParameters {
        let sessionDuration: Minutes
    }

    struct AuthenticateStartParameters: Encodable {
        let publicKey: Data
        let userId: String
    }

    struct AuthenticateStartResponse: Codable {
        let challenge: Data
        let biometricRegistrationId: String
    }

    struct AuthenticateFinishParameters: Encodable {
        let signature: Data
        let biometricRegistrationId: String
        let sessionDurationMinutes: Minutes
    }

    struct Registration {
        public let userLabel: String
        public let createdAt: Date
        let index: Int
    }

    struct RegisterParameters {
        // email or phone number
        let identifier: String
        let accessPolicy: AccessPolicy
        let syncingBehavior: SyncingBehavior

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

        enum SyncingBehavior {
            case disabled
            case enabled

            var keychainValue: KeychainClient.Item.SyncingBehavior {
                switch self {
                case .disabled:
                    return .disabled
                case .enabled:
                    return .enabled
                }
            }
        }
    }

    private struct RegisterStartParameters: Encodable {
        let publicKey: Data
    }

    private struct RegisterStartResponse: Decodable {
        let biometricRegistrationId: String
        let challenge: Data
    }

    private struct RegisterFinishParameters: Encodable {
        let biometricRegistrationId: String
        let signature: Data
    }

    private struct RegisterFinishResponseData: Codable {
        let biometricRegistrationId: String
        let user: User
    }
}
#endif
