import Foundation

struct KeychainItem {
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
        return querySegment
    }
}

extension KeychainItem {
    enum Kind {
        case privateKey
        case encryptionKey
        case deprecated
    }
}

extension KeychainItem {
    struct Value {
        let data: Data
        let account: String?
        let label: String?
        let generic: Data?
        let accessPolicy: AccessPolicy?
    }
}

extension KeychainItem {
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

                defer {
                    error?.release()
                }

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

                if let accessControl = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, flags, &error) {
                    return accessControl
                } else {
                    throw error.toError() ?? KeychainError.unableToCreateAccessControl
                }
            }
        }
    }
}

extension KeychainItem {
    // The private key registration is central to biometric authentication, and this item should be protected by biometrics unless explicitly specified otherwise by the caller.
    static let privateKeyRegistration: Self = .init(kind: .privateKey, name: "stytch_private_key_registration")
    static let encryptionKey: Self = .init(kind: .encryptionKey, name: "stytch_encryption_key")

    // The following key types are deprecated, but exist for backwards compatibility with migrations
    static let biometricKeyRegistration: Self = .init(kind: .deprecated, name: "stytch_biometric_key_registration")
    static let sessionToken: Self = .init(kind: .deprecated, name: SessionToken.Kind.opaque.name)
    static let sessionJwt: Self = .init(kind: .deprecated, name: SessionToken.Kind.jwt.name)
    static let intermediateSessionToken: Self = .init(kind: .deprecated, name: "stytch_intermediate_session_token")
    static let codeVerifierPKCE: Self = .init(kind: .deprecated, name: "stytch_code_verifier_pkce")
    static let codeChallengePKCE: Self = .init(kind: .deprecated, name: "stytch_code_challenge_pkce")
    static let session: Self = .init(kind: .deprecated, name: "stytch_session_object")
    static let memberSession: Self = .init(kind: .deprecated, name: "stytch_member_session_object")
    static let user: Self = .init(kind: .deprecated, name: "stytch_user_object")
    static let member: Self = .init(kind: .deprecated, name: "stytch_member_object")
    static let organization: Self = .init(kind: .deprecated, name: "stytch_organization_object")
    static let b2bLastAuthMethodUsed: Self = .init(kind: .deprecated, name: "b2b_last_auth_method_used")
    static let consumerLastAuthMethodUsed: Self = .init(kind: .deprecated, name: "consumer_last_auth_method_used")

    // TODO: - set up linting or codegen to ensure any new `KeychainItem` added (this file or elsewhere) is added to this array
    static var allItems: [Self] {
        [
            .privateKeyRegistration,
            .encryptionKey,
        ]
    }
}
