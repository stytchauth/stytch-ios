import Foundation

extension KeychainClient {
    struct QueryResult {
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

    struct KeyRegistration: Codable {
        let userId: User.ID
        let userLabel: String
        let registrationId: User.BiometricRegistration.ID
    }

    enum KeychainError: Swift.Error {
        case resultMissingAccount
        case resultMissingDates
        case resultNotArray
        case resultNotData
        case unableToCreateAccessControl
        case unhandledError(status: OSStatus)
    }
}
