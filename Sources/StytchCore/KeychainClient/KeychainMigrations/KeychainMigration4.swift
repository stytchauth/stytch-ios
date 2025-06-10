import Foundation
import Security

struct KeychainMigration4: KeychainMigration {
    static let keychainClient = Current.keychainClient
    static let userDefaultsClient = Current.userDefaultsClient

    static func run() throws {
        try [
            (KeychainItem.biometricKeyRegistration, EncryptedUserDefaultsItem.biometricKeyRegistration),
            (KeychainItem.sessionToken, EncryptedUserDefaultsItem.sessionToken),
            (KeychainItem.sessionJwt, EncryptedUserDefaultsItem.sessionJwt),
            (KeychainItem.intermediateSessionToken, EncryptedUserDefaultsItem.intermediateSessionToken),
            (KeychainItem.codeVerifierPKCE, EncryptedUserDefaultsItem.codeVerifierPKCE),
            (KeychainItem.codeChallengePKCE, EncryptedUserDefaultsItem.codeChallengePKCE),
            (KeychainItem.session, EncryptedUserDefaultsItem.session),
            (KeychainItem.memberSession, EncryptedUserDefaultsItem.memberSession),
            (KeychainItem.user, EncryptedUserDefaultsItem.user),
            (KeychainItem.member, EncryptedUserDefaultsItem.member),
            (KeychainItem.organization, EncryptedUserDefaultsItem.organization),
            (KeychainItem.b2bLastAuthMethodUsed, EncryptedUserDefaultsItem.b2bLastAuthMethodUsed),
            (KeychainItem.consumerLastAuthMethodUsed, EncryptedUserDefaultsItem.consumerLastAuthMethodUsed),
        ]
        .forEach { (keyChainKey, userDefaultsKey) in
            // fetch data from keychain
            let results = try keychainClient.getQueryResults(item: keyChainKey)
            guard let keychainData = results.first, let keychainDataString = keychainData.stringValue else { return }
            // save to userdefaults
            try userDefaultsClient.setStringValue(keychainDataString, for: userDefaultsKey)
        }
    }
}
