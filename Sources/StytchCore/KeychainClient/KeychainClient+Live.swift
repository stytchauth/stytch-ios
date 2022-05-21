import Foundation
import Security

extension KeychainClient {
    static let live: Self = .init { item in
        var result: CFTypeRef?

        guard case errSecSuccess = SecItemCopyMatching(item.getQuery, &result) else {
            return nil
        }
        guard let data = result as? Data else {
            throw KeychainError.resultNotData
        }

        return String(data: data, encoding: .utf8)
    } setValueForItem: { client, value, item in
        let status: OSStatus

        if client.resultExists(for: item) {
            status = SecItemUpdate(
                item.baseQuery as CFDictionary,
                item.querySegmentForUpdate(for: value) as CFDictionary
            )
        } else {
            status = SecItemAdd(item.insertQuery(value: value), nil)
        }
        if status != errSecSuccess {
            throw KeychainError.unhandledError(status: status)
        }
    } removeItem: { client, item in
        guard client.resultExists(for: item) else {
            return
        }

        let status = SecItemDelete(item.baseQuery as CFDictionary)

        if status != errSecSuccess {
            throw KeychainError.unhandledError(status: status)
        }
    } resultExists: { item in
        SecItemCopyMatching(item.baseQuery as CFDictionary, nil) == errSecSuccess
    } publicKeyForItem: { client, item in
        var error: Unmanaged<CFError>?

        let externalRepresentationForKey: (SecKey, inout Unmanaged<CFError>?) throws -> String = { key, error in
            guard let externalRepresentationData = SecKeyCopyExternalRepresentation(key, &error) as? Data else {
                throw error.toError() ?? KeychainError.publicKeyExternalRepresentationCreationFailed
            }

            return externalRepresentationData.base64EncodedString()
        }

        if let publicKey = try client.fetchKeyForItem(item, .public) {
            return try externalRepresentationForKey(publicKey, &error)
        }

        guard case let .keyPair(appStatusOption) = item.kind else { throw KeychainError.keychainItemKindMistmatch }

        let accessControl: SecAccessControlCreateFlags

        if #available(iOS 11.3, macOS 10.13.4, tvOS 11.3, watchOS 4.3, *) {
            accessControl = [.biometryCurrentSet]
        } else {
            accessControl = [.touchIDCurrentSet]
        }

        guard let accessControl = SecAccessControlCreateWithFlags(nil, appStatusOption.value, accessControl, &error) else {
            throw error.toError() ?? KeychainError.accessControlCreationFailed
        }

        let query = item.createKeyPairQuery(accessControl: accessControl)

        guard let privateKey = SecKeyCreateRandomKey(query as CFDictionary, &error) else {
            throw error.toError() ?? KeychainError.privateKeyGenerationFailed
        }

        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw KeychainError.publicKeyGenerationFailed
        }

        return try externalRepresentationForKey(publicKey, &error)
    } fetchKeyForItem: { item, keyClass in
        let query = item.getKeyQuery(keyClass: keyClass)

        var result: AnyObject?

        let queryStatus = SecItemCopyMatching(query as CFDictionary, &result)

        if queryStatus == errSecItemNotFound {
            return nil
        }

        guard queryStatus == errSecSuccess else {
            throw KeychainError.unhandledError(status: queryStatus)
        }

        guard let result = result, let castedKey = result as? SecKey?, let key = castedKey else {
            throw KeychainError.notSecKey
        }

        return key
    } signChallenge: { client, challenge, item, algorithm in
        var error: Unmanaged<CFError>?

        guard let privateKey = try client.fetchKeyForItem(item, .private) else {
            throw KeychainError.noPrivateKeyFound
        }

        guard
            case let algorithm: SecKeyAlgorithm = .init(rawValue: algorithm as CFString),
            SecKeyIsAlgorithmSupported(privateKey, .sign, algorithm)
        else {
            throw KeychainError.signingNotSupportedWithAlgorithm(algorithm)
        }

        guard let signatureData = SecKeyCreateSignature(
            privateKey,
            algorithm,
            Data(challenge.utf8) as CFData,
            &error
        ) as? Data else {
            throw error.toError() ?? KeychainError.challengeSigningFailed
        }

        return signatureData.base64EncodedString()
    }
}
