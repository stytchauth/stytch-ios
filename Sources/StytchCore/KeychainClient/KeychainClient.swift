import Foundation

struct KeychainClient {
    private let get: (Item) throws -> [QueryResult]

    let setValueForItem: (Self, ItemData, Item) throws -> Void

    let removeItem: (Item) throws -> Void

    let resultsExistForItem: (Item) -> Bool

    init(
        get: @escaping (Item) throws -> [QueryResult],
        setValueForItem: @escaping (Self, ItemData, Item) throws -> Void,
        removeItem: @escaping (Item) throws -> Void,
        resultsExistForItem: @escaping (Item) -> Bool
    ) {
        self.get = get
        self.setValueForItem = setValueForItem
        self.removeItem = removeItem
        self.resultsExistForItem = resultsExistForItem
    }
}

// String convenience methods
extension KeychainClient {
    func get(_ item: Item) throws -> String? {
        try get(item)
            .first
            .flatMap { String(data: $0.data, encoding: .utf8) }
    }

    func set(_ value: String, for item: Item) throws {
        try setValueForItem(
            self,
            .init(data: .init(value.utf8), account: nil, label: nil, generic: nil, accessControl: nil),
            item
        )
    }
}

extension KeychainClient {
    struct QueryResult {
        let data: Data
        let createdAt: Date
        let modifiedAt: Date
        let label: String?
        let account: String
        let generic: Data?
    }

    struct ItemData {
        let data: Data
        let account: String?
        let label: String?
        let generic: Data?
        let accessControl: AccessControl?

        enum AccessControl {
            var value: SecAccessControl {
                switch self {}
            }
        }
    }

    struct Item {
        enum Kind {
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

        var getQuery: CFDictionary {
            baseQuery
                .merging([
                    kSecReturnData: true,
                    kSecReturnAttributes: true,
                    kSecMatchLimit: kSecMatchLimitAll,
                ]) { $1 } as CFDictionary
        }

        func insertQuery(itemData: ItemData) -> CFDictionary {
            baseQuery.merging(updateQuerySegment(for: itemData))
        }

        func updateQuerySegment(for itemData: ItemData) -> [CFString: Any] {
            var querySegment: [CFString: Any] = [
                kSecValueData: itemData.data,
            ]
            if let account = itemData.account {
                querySegment[kSecAttrAccount] = account
            }
            if let label = itemData.label {
                querySegment[kSecAttrLabel] = label
            }
            if let generic = itemData.generic {
                querySegment[kSecAttrGeneric] = generic
            }
            if let accessControl = itemData.accessControl?.value {
                querySegment[kSecAttrAccessControl] = accessControl // FIXME: - messed up on ios 15 simulator
            }
            return querySegment
        }
    }

    enum KeychainError: Swift.Error {
        case resultMissingAccount
        case resultMissingDates
        case resultNotArray
        case resultNotData
        case unhandledError(status: OSStatus)
    }
}

extension KeychainClient.Item {
    static let stytchEMLPKCECodeVerifier: Self = .init(kind: .token, name: "stytch_eml_pkce_code_verifier")
    static let stytchPWResetByEmailPKCECodeVerifier: Self = .init(kind: .token, name: "stytch_password_reset_by_email_pkce_code_verifier")
}

extension Dictionary where Key == CFString, Value == Any {
    func merging(_ other: Self) -> CFDictionary {
        merging(other) { $1 } as CFDictionary
    }
}
