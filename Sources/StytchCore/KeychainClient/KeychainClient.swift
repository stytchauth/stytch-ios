import Foundation

struct KeychainClient {
    private let getItem: (Self, Item) throws -> String?

    private let setValueForItem: (Self, String, Item) throws -> Void

    private let removeItem: (Self, Item) throws -> Void

    private let resultExists: (Item) -> Bool

    init(
        getItem: @escaping (KeychainClient, KeychainClient.Item) throws -> String?,
        setValueForItem: @escaping (KeychainClient, String, KeychainClient.Item) throws -> Void,
        removeItem: @escaping (KeychainClient, KeychainClient.Item) throws -> Void,
        resultExists: @escaping (KeychainClient.Item) -> Bool
    ) {
        self.getItem = getItem
        self.setValueForItem = setValueForItem
        self.removeItem = removeItem
        self.resultExists = resultExists
    }

    func get(_ item: Item) throws -> String? {
        try getItem(self, item)
    }

    func set(_ value: String, for item: Item) throws {
        try setValueForItem(self, value, item)
    }

    func remove(_ item: Item) throws {
        try removeItem(self, item)
    }

    func resultExists(for item: Item) -> Bool {
        resultExists(item)
    }
}

extension KeychainClient {
    struct Item {
        enum Kind {
            case token
        }

        var kind: Kind

        var name: String

        var baseQuery: [CFString: Any] {
            var query: [CFString: Any] = [
                kSecClass: secClass,
                kSecAttrAccount: name,
            ]
            #if os(macOS)
            if #available(macOS 10.15, *) {
                query[kSecUseDataProtectionKeychain] = true
            }
            #endif
            return query
        }

        var getQuery: CFDictionary {
            baseQuery
                .merging([
                    kSecReturnData: true,
                    kSecMatchLimit: kSecMatchLimitOne,
                ]) { $1 } as CFDictionary
        }

        func insertQuery(value: String) -> CFDictionary {
            baseQuery.merging(querySegmentForUpdate(for: value)) { $1 } as CFDictionary
        }

        func querySegmentForUpdate(for value: String) -> [CFString: Any] {
            [kSecValueData: Data(value.utf8)]
        }

        private var secClass: CFString {
            switch kind {
            case .token:
                return kSecClassGenericPassword
            }
        }
    }

    enum KeychainError: Swift.Error {
        case resultNotData
        case unhandledError(status: OSStatus)
    }
}
