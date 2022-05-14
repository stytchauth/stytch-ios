import Foundation

public struct User: Codable {
    public let createdAt: Date
    public let cryptoWallets: [CryptoWallet]
    public let emails: [Email]
    public var id: String { userId }
    let userId: String
    public let name: Name
    public let phoneNumbers: [PhoneNumber]
    public let providers: [Provider]
    public let status: Status
    public let totps: [TOTP]
    public let webauthnRegistrations: [WebAuthNRegistrations]
}

public extension User {
    struct CryptoWallet: Codable {
        public var id: String { cryptoWalletId }
        let cryptoWalletId: String
        public var address: String { cryptoWalletAddress }
        let cryptoWalletAddress: String
        public var walletType: String { cryptoWalletType }
        let cryptoWalletType: String
        public let verified: Bool
    }

    struct Email: Codable {
        public let email: String
        public var id: String { emailId }
        let emailId: String
        public let verified: Bool
    }

    struct Name: Codable {
        public let firstName: String
        public let lastName: String
        public let middleName: String
    }

    struct Provider: Codable {
        public let providerSubject: String
        public let providerType: String
    }

    struct PhoneNumber: Codable {
        public let phoneNumber: String
        public var id: String { phoneId }
        let phoneId: String
        public let verified: Bool
    }

    enum Status: String, Codable {
        case active, pending
    }

    struct TOTP: Codable {
        public var id: String { totpId }
        let totpId: String
        public let verified: Bool
    }

    struct WebAuthNRegistrations: Codable {
        public let domain: String
        public let userAgent: String
        public let verified: Bool
        public var id: String { webauthnRegistrationId }
        let webauthnRegistrationId: String
    }
}
