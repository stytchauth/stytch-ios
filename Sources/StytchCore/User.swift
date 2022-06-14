import Foundation

public struct User: Codable {
    /// The date the user was originally created.
    public let createdAt: Date
    /// The user's cryptowallets.
    public let cryptoWallets: [CryptoWallet]
    /// The user's emails'
    public let emails: [Email]
    /// The id of the user.
    public var id: String { userId }
    let userId: String
    /// The user's name.
    public let name: Name
    /// The user's phone numbers.
    public let phoneNumbers: [PhoneNumber]
    /// The user's oauth providers.
    public let providers: [Provider]
    /// The status of the user.
    public let status: UserStatus
    /// The user's totps.
    public let totps: [TOTP]
    /// The user's WebAuthn registrations.
    public let webauthnRegistrations: [WebAuthNRegistrations]
}

public extension User {
    struct CryptoWallet: Codable {
        /// The id of the crypto wallet.
        public var id: String { cryptoWalletId }
        let cryptoWalletId: String
        /// The address of the cryptowallet.
        public var address: String { cryptoWalletAddress }
        let cryptoWalletAddress: String
        /// The type of the cryptowallet.
        public var walletType: String { cryptoWalletType }
        let cryptoWalletType: String
        /// The verification status of the cryptowallet.
        public let verified: Bool
    }

    struct Email: Codable {
        /// The email address.
        public let email: String
        /// The id of the email.
        public var id: String { emailId }
        let emailId: String
        /// The verification status of the email.
        public let verified: Bool
    }

    struct Name: Codable {
        /// The user's first name.
        public let firstName: String?
        /// The user's last name.
        public let lastName: String?
        /// The user's middle name.
        public let middleName: String?
    }

    struct Provider: Codable {
        /// The subject of the provider.
        public let providerSubject: String
        /// The type of the provider.
        public let providerType: String
    }

    struct PhoneNumber: Codable {
        /// The phone number.
        public let phoneNumber: String
        /// The id of the phone number.
        public var id: String { phoneId }
        let phoneId: String
        /// The verification status of the phone number.
        public let verified: Bool
    }

    enum UserStatus: String, Codable {
        /// The user is an active user.
        case active
        /// The user is still in a pending status.
        case pending
    }

    struct TOTP: Codable {
        /// The id of the TOTP.
        public var id: String { totpId }
        let totpId: String
        /// The verification status of the TOTP.
        public let verified: Bool
    }

    struct WebAuthNRegistrations: Codable {
        /// The domain of the WebAuthN registration.
        public let domain: String
        /// The user agent of the registration.
        public let userAgent: String
        /// The verification status of the registration.
        public let verified: Bool
        /// The id of the registration.
        public var id: String { webauthnRegistrationId }
        let webauthnRegistrationId: String
    }
}
