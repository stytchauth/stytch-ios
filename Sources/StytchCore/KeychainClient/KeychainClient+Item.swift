import Foundation

extension KeychainClient {
    struct Item {
        enum Kind {
            case privateKey
            case token
        }

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
            if let accessControl = try? value.accessPolicy?.accessControl(syncingBehavior: value.syncingBehavior) {
                querySegment[kSecAttrAccessControl] = accessControl // FIXME: - messed up on ios 15 simulator
            }
            if case .enabled = value.syncingBehavior {
                querySegment[kSecAttrSynchronizable] = kCFBooleanTrue
            }
            return querySegment
        }
    }
}

extension KeychainClient.Item {
    static let privateKeyRegistration: Self = .init(kind: .privateKey, name: "stytch_private_key_registration")
    static let sessionToken: Self = .init(kind: .token, name: Session.Token.Kind.opaque.name)
    static let sessionJwt: Self = .init(kind: .token, name: Session.Token.Kind.jwt.name)
    static let stytchPKCECodeVerifier: Self = .init(kind: .token, name: "stytch_pkce_code_verifier")
}

extension KeychainClient.Item {
    struct Value {
        let data: Data
        let account: String?
        let label: String?
        let generic: Data?
        let accessPolicy: AccessPolicy?
        let syncingBehavior: SyncingBehavior
    }

    enum SyncingBehavior {
        case disabled
        case enabled
    }

    enum AccessPolicy {
        case deviceOwnerAuthentication
        case deviceOwnerAuthenticationWithBiometrics
        #if os(macOS)
        // swiftlint:disable:next identifier_name
        case deviceOwnerAuthenticationWithBiometricsOrWatch
        #endif
    }
}

private extension KeychainClient.Item.AccessPolicy {
    func accessControl(syncingBehavior: KeychainClient.Item.SyncingBehavior) throws -> SecAccessControl {
        var error: Unmanaged<CFError>?
        defer { error?.release() }

        let flags: SecAccessControlCreateFlags
        let protection: CFString

        switch syncingBehavior {
        case .enabled:
            protection = kSecAttrAccessibleWhenUnlocked
        case .disabled:
            protection = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        }

        // TODO: - check on use of xxxCurrentSet for synced keys, does this work?
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

        guard let accessControl = SecAccessControlCreateWithFlags(nil, protection, flags, &error) else {
            throw error.toError() ?? KeychainClient.KeychainError.resultNotData // TODO: - specific error
        }

        return accessControl
    }
}
