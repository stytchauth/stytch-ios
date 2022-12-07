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
    /// The user's passwords.
    public let password: Password?
    /// The user's phone numbers.
    public let phoneNumbers: [PhoneNumber]
    /// The user's oauth providers.
    public let providers: [Provider]
    /// The status of the user.
    public let status: UserStatus
    /// The user's totps.
    public let totps: [TOTP]
    /// The user's WebAuthn registrations.
    public let webauthnRegistrations: [WebAuthNRegistration]
    /// The user's Biometric registrations.
    public let biometricRegistrations: [BiometricRegistration]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.cryptoWallets = try container.decodeIfPresent([User.CryptoWallet].self, forKey: .cryptoWallets) ?? []
        self.emails = try container.decodeIfPresent([User.Email].self, forKey: .emails) ?? []
        self.userId = try container.decode(String.self, forKey: .userId)
        self.name = try container.decode(User.Name.self, forKey: .name)
        self.password = try container.decodeIfPresent(User.Password.self, forKey: .password)
        self.phoneNumbers = try container.decodeIfPresent([User.PhoneNumber].self, forKey: .phoneNumbers) ?? []
        self.providers = try container.decodeIfPresent([User.Provider].self, forKey: .providers) ?? []
        self.status = try container.decode(User.UserStatus.self, forKey: .status)
        self.totps = try container.decodeIfPresent([User.TOTP].self, forKey: .totps) ?? []
        self.webauthnRegistrations = try container.decodeIfPresent([User.WebAuthNRegistration].self, forKey: .webauthnRegistrations) ?? []
        self.biometricRegistrations = try container.decodeIfPresent([User.BiometricRegistration].self, forKey: .biometricRegistrations) ?? []
    }
}

public extension User {
    struct Password: Codable {
        public var id: String { passwordId }
        let passwordId: String
        let requiresReset: Bool
    }

    struct CryptoWallet: Codable {
        public typealias ID = Identifier<Self, String>
        /// The id of the crypto wallet.
        public var id: ID { cryptoWalletId }
        let cryptoWalletId: ID
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
        public typealias ID = Identifier<Self, String>
        /// The email address.
        public let email: String
        /// The id of the email.
        public var id: ID { emailId }
        let emailId: ID
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

        public init(firstName: String? = nil, lastName: String? = nil, middleName: String? = nil) {
            self.firstName = firstName
            self.lastName = lastName
            self.middleName = middleName
        }
    }

    struct Provider: Codable {
        /// The subject of the provider.
        public let providerSubject: String
        /// The type of the provider.
        public let providerType: String
    }

    struct PhoneNumber: Codable {
        public typealias ID = Identifier<Self, String>
        /// The phone number.
        public let phoneNumber: String
        /// The id of the phone number.
        public var id: ID { phoneId }
        let phoneId: ID
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
        public typealias ID = Identifier<Self, String>
        /// The id of the TOTP.
        public var id: ID { totpId }
        let totpId: ID
        /// The verification status of the TOTP.
        public let verified: Bool
    }

    struct WebAuthNRegistration: Codable {
        public typealias ID = Identifier<Self, String>
        /// The domain of the WebAuthN registration.
        public let domain: String
        /// The user agent of the registration.
        public let userAgent: String
        /// The verification status of the registration.
        public let verified: Bool
        /// The id of the registration.
        public var id: ID { webauthnRegistrationId }
        let webauthnRegistrationId: ID
    }

    struct BiometricRegistration: Codable {
        public typealias ID = Identifier<Self, String>
        /// The verification status of the registration.
        public let verified: Bool
        /// The id of the registration.
        public var id: ID { biometricRegistrationId }
        let biometricRegistrationId: ID
    }
}
