// swiftlint:disable nesting

import Foundation

public struct User: Decodable {
    public let createdAt: Date
    public let cryptoWallets: [CryptoWallet]
    public let emails: [Email]
    public let userId: String // TODO: make this just id
    public let name: Name
    public let phoneNumbers: [PhoneNumber]
    public let providers: [Provider]
    public let status: Status
    public let totps: [TOTP]
    public let webauthnRegistrations: [WebAuthNRegistrations]
}

public extension User {
    struct CryptoWallet: Decodable {
        private enum CodingKeys: String, CodingKey {
            case id = "crypto_wallet_id"
            case address = "crypto_wallet_address"
            case verified
            case walletType = "crypto_wallet_type"
        }

        public let id: String
        public let address: String
        public let walletType: String
        public let verified: Bool
    }
    struct Email: Decodable {
        public let email: String
        public let emailId: String
        public let verified: Bool
    }
    struct Name: Decodable {
        public let firstName: String
        public let lastName: String
        public let middleName: String
    }
    struct Provider: Decodable {
        public let providerSubject: String
        public let providerType: String
    }
    struct PhoneNumber: Decodable {
        public let phoneNumber: String
        public let phoneId: String
        public let verified: Bool
    }
    enum Status: String, Decodable {
        case active, pending
    }
    struct TOTP: Decodable {
        public let totpId: String
        public let verified: Bool
    }
    struct WebAuthNRegistrations: Decodable {
        public let domain: String
        public let userAgent: String
        public let verified: Bool
        public let webauthnRegistrationId: String // TODO: - make id
    }
}
