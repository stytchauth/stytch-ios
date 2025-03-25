import Foundation

extension KeychainClient {
    struct Item {
        var kind: Kind
        var name: String

        var baseQuery: [CFString: Any] {
            [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: name,
                kSecUseDataProtectionKeychain: true,
            ]
        }

        var getQuery: [CFString: Any] {
            baseQuery
                .merging([
                    kSecReturnData: true,
                    kSecReturnAttributes: true,
                    kSecMatchLimit: kSecMatchLimitAll,
                    kSecAttrSynchronizable: kSecAttrSynchronizableAny,
                ]) { $1 }
        }

        func insertQuery(value: Value) -> CFDictionary {
            baseQuery.merging(updateQuerySegment(for: value))
        }

        func updateQuerySegment(for value: Value) -> [CFString: Any] {
            var querySegment: [CFString: Any] = [
                kSecValueData: value.data,
            ]
            if let account = value.account {
                querySegment[kSecAttrAccount] = account
            }
            if let label = value.label {
                querySegment[kSecAttrLabel] = label
            }
            if let generic = value.generic {
                querySegment[kSecAttrGeneric] = generic
            }
            if let accessControl = try? value.accessPolicy?.accessControl {
                querySegment[kSecAttrAccessControl] = accessControl
            }
            if kind == .token {
                querySegment[kSecAttrAccessible] = kSecAttrAccessibleAfterFirstUnlock
            }
            return querySegment
        }
    }
}

extension KeychainClient.Item {
    enum Kind {
        case privateKey
        case token
        case object
    }
}

extension KeychainClient.Item {
    struct Value {
        let data: Data
        let account: String?
        let label: String?
        let generic: Data?
        let accessPolicy: AccessPolicy?
    }
}

extension KeychainClient.Item {
    enum AccessPolicy {
        case deviceOwnerAuthentication
        case deviceOwnerAuthenticationWithBiometrics
        #if os(macOS)
        // swiftlint:disable:next identifier_name
        case deviceOwnerAuthenticationWithBiometricsOrWatch
        #endif

        var accessControl: SecAccessControl {
            get throws {
                var error: Unmanaged<CFError>?
                defer { error?.release() }

                let flags: SecAccessControlCreateFlags

                switch self {
                case .deviceOwnerAuthentication:
                    flags = [.userPresence]
                case .deviceOwnerAuthenticationWithBiometrics:
                    flags = [.biometryCurrentSet]
                #if os(macOS)
                case .deviceOwnerAuthenticationWithBiometricsOrWatch:
                    flags = [.biometryCurrentSet, .or, .watch]
                #endif
                }

                guard
                    let accessControl = SecAccessControlCreateWithFlags(
                        nil,
                        kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                        flags,
                        &error
                    )
                else {
                    throw error.toError() ?? KeychainClient.KeychainError.unableToCreateAccessControl
                }

                return accessControl
            }
        }
    }
}

extension KeychainClient.Item {
    // The private key registration is central to biometric authentication, and this item should be protected by biometrics unless explicitly specified otherwise by the caller.
    static let privateKeyRegistration: Self = .init(kind: .privateKey, name: "stytch_private_key_registration")
    // This was introduced in version 0.54.0 to store the biometric registration ID in a keychain item that is not protected by biometrics.
    static let biometricKeyRegistration: Self = .init(kind: .object, name: "stytch_biometric_key_registration")

    static let sessionToken: Self = .init(kind: .token, name: SessionToken.Kind.opaque.name)
    static let sessionJwt: Self = .init(kind: .token, name: SessionToken.Kind.jwt.name)
    static let intermediateSessionToken: Self = .init(kind: .token, name: "stytch_intermediate_session_token")

    static let codeVerifierPKCE: Self = .init(kind: .token, name: "stytch_code_verifier_pkce")
    static let codeChallengePKCE: Self = .init(kind: .token, name: "stytch_code_challenge_pkce")

    static let session: Self = .init(kind: .object, name: "stytch_session_object")
    static let memberSession: Self = .init(kind: .object, name: "stytch_member_session_object")
    static let user: Self = .init(kind: .object, name: "stytch_user_object")
    static let member: Self = .init(kind: .object, name: "stytch_member_object")
    static let organization: Self = .init(kind: .object, name: "stytch_organization_object")

    static let b2bLastAuthMethodUsed: Self = .init(kind: .object, name: "b2b_last_auth_method_used")
    static let consumerLastAuthMethodUsed: Self = .init(kind: .object, name: "consumer_last_auth_method_used")

    // TODO: - set up linting or codegen to ensure any new `KeychainClient.Item` added (this file or elsewhere) is added to this array
    static var allItems: [Self] {
        [
            .privateKeyRegistration,
            .biometricKeyRegistration,
            .sessionToken,
            .sessionJwt,
            .intermediateSessionToken,
            .codeVerifierPKCE,
            .codeChallengePKCE,
            .session,
            .memberSession,
            .user,
            .member,
            .organization,
            .b2bLastAuthMethodUsed,
            .consumerLastAuthMethodUsed,
        ]
    }
}
