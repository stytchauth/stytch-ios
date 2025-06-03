import Foundation

protocol KeychainClient: AnyObject {
    func getQueryResults(item: KeychainItem) throws -> [KeychainQueryResult]
    func valueExistsForItem(item: KeychainItem) -> Bool
    func setValueForItem(value: KeychainItem.Value, item: KeychainItem) throws
    func removeItem(item: KeychainItem) throws
}

extension KeychainClient {
    func getFirstQueryResult(_ item: KeychainItem) throws -> KeychainQueryResult? {
        try getQueryResults(item: item).first
    }

    func getStringValue(_ item: KeychainItem) throws -> String? {
        try getQueryResults(item: item)
            .first
            .flatMap(\.stringValue)
    }

    func getObject<T: Decodable>(_: T.Type, for item: KeychainItem) throws -> T? {
        guard let result = try getFirstQueryResult(item) else {
            return nil
        }
        return try Current.jsonDecoder.decode(T.self, from: result.data)
    }

    func setStringValue(_ value: String, for item: KeychainItem) throws {
        try setValueForItem(
            value: .init(data: .init(value.utf8), account: nil, label: nil, generic: nil, accessPolicy: nil),
            item: item
        )
    }

    func setObject(_ object: any Codable, for item: KeychainItem) throws {
        let encodedData = try Current.jsonEncoder.encode(object)
        try setValueForItem(
            value: .init(data: encodedData, account: nil, label: nil, generic: nil, accessPolicy: nil),
            item: item
        )
    }

    func setPrivateKeyRegistration(
        key: Data,
        registration: BiometricPrivateKeyRegistration,
        accessPolicy: KeychainItem.AccessPolicy
    ) throws {
        try setValueForItem(
            value: .init(
                data: key,
                account: nil, // By setting as nil, the primary key will be the KeychainItem.name and nil, thus allowing only one registration to be stored.
                label: registration.userLabel,
                generic: Current.jsonEncoder.encode(registration),
                accessPolicy: accessPolicy
            ),
            item: .privateKeyRegistration
        )
    }
}

struct KeychainQueryResult {
    let data: Data
    let createdAt: Date
    let modifiedAt: Date
    let label: String?
    let account: String?
    let generic: Data?

    var stringValue: String? {
        String(data: data, encoding: .utf8)
    }
}

struct BiometricPrivateKeyRegistration: Codable {
    let userId: User.ID
    let userLabel: String
    let registrationId: User.BiometricRegistration.ID
}

public enum KeychainError: Swift.Error, Equatable {
    case resultMissingAccount
    case resultMissingDates
    case resultNotArray
    case resultNotData
    case unableToCreateAccessControl
    case unhandledError(status: OSStatus)
}
