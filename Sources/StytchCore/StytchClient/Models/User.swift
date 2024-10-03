import Foundation

/// A type defining a user; including information about their name, status, the auth factors associated with them, and more.
public struct User {
    public typealias ID = Identifier<Self, String>

    /// The date the user was originally created.
    public let createdAt: Date
    /// The user's cryptowallets.
    public let cryptoWallets: [CryptoWallet]
    /// The user's emails'
    public let emails: [Email]
    /// The id of the user.
    public var id: ID { userId }
    let userId: ID
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
    /// The user's untrusted metadata
    public let untrustedMetadata: JSON?
    /// The user's trusted metadata
    public let trustedMetadata: JSON?
}

extension User: Equatable {
    public static func == (lhs: User, rhs: User) -> Bool {
        lhs.createdAt == rhs.createdAt &&
            lhs.cryptoWallets == rhs.cryptoWallets &&
            lhs.emails == rhs.emails &&
            lhs.userId == rhs.userId &&
            lhs.name == rhs.name &&
            lhs.password == rhs.password &&
            lhs.phoneNumbers == rhs.phoneNumbers &&
            lhs.providers == rhs.providers &&
            lhs.status == rhs.status &&
            lhs.totps == rhs.totps &&
            lhs.webauthnRegistrations == rhs.webauthnRegistrations &&
            lhs.biometricRegistrations == rhs.biometricRegistrations &&
            lhs.untrustedMetadata == rhs.untrustedMetadata &&
            lhs.trustedMetadata == rhs.trustedMetadata
    }
}

extension User: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        createdAt = try container.decode(key: .createdAt)
        cryptoWallets = try container.optionalDecode(key: .cryptoWallets) ?? []
        emails = try container.optionalDecode(key: .emails) ?? []
        userId = try container.decode(key: .userId)
        name = try container.decode(key: .name)
        password = try container.optionalDecode(key: .password)
        phoneNumbers = try container.optionalDecode(key: .phoneNumbers) ?? []
        providers = try container.optionalDecode(key: .providers) ?? []
        status = try container.decode(key: .status)
        totps = try container.optionalDecode(key: .totps) ?? []
        webauthnRegistrations = try container.optionalDecode(key: .webauthnRegistrations) ?? []
        biometricRegistrations = try container.optionalDecode(key: .biometricRegistrations) ?? []
        untrustedMetadata = try container.optionalDecode(key: .untrustedMetadata)
        trustedMetadata = try container.optionalDecode(key: .trustedMetadata)
    }
}

public extension User {
    struct Password: Codable, Equatable {
        public typealias ID = Identifier<Self, String>

        public var id: ID { passwordId }
        let passwordId: ID
        let requiresReset: Bool

        public static func == (lhs: Password, rhs: Password) -> Bool {
            lhs.passwordId == rhs.passwordId &&
                lhs.requiresReset == rhs.requiresReset
        }
    }

    struct CryptoWallet: Codable, Equatable {
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

        public static func == (lhs: CryptoWallet, rhs: CryptoWallet) -> Bool {
            lhs.cryptoWalletId == rhs.cryptoWalletId &&
                lhs.cryptoWalletAddress == rhs.cryptoWalletAddress &&
                lhs.cryptoWalletType == rhs.cryptoWalletType &&
                lhs.verified == rhs.verified
        }
    }

    struct Email: Codable, Equatable {
        public typealias ID = Identifier<Self, String>
        /// The email address.
        public let email: String
        /// The id of the email.
        public var id: ID { emailId }
        let emailId: ID
        /// The verification status of the email.
        public let verified: Bool

        public static func == (lhs: Email, rhs: Email) -> Bool {
            lhs.email == rhs.email &&
                lhs.emailId == rhs.emailId &&
                lhs.verified == rhs.verified
        }
    }

    struct Name: Codable, Equatable {
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

        public static func == (lhs: Name, rhs: Name) -> Bool {
            lhs.firstName == rhs.firstName &&
                lhs.lastName == rhs.lastName &&
                lhs.middleName == rhs.middleName
        }
    }

    struct Provider: Codable, Equatable {
        public typealias ID = Identifier<Self, String>
        /// The subject of the provider.
        public let providerSubject: String
        /// The type of the provider.
        public let providerType: String
        /// The profile picture set for the provider
        public let profilePictureUrl: String?
        /// The id of the registration.
        public var id: ID { oauthUserRegistrationId }
        let oauthUserRegistrationId: ID

        public static func == (lhs: Provider, rhs: Provider) -> Bool {
            lhs.providerSubject == rhs.providerSubject &&
                lhs.providerType == rhs.providerType &&
                lhs.profilePictureUrl == rhs.profilePictureUrl &&
                lhs.oauthUserRegistrationId == rhs.oauthUserRegistrationId
        }
    }

    struct PhoneNumber: Codable, Equatable {
        public typealias ID = Identifier<Self, String>
        /// The phone number.
        public let phoneNumber: String
        /// The id of the phone number.
        public var id: ID { phoneId }
        let phoneId: ID
        /// The verification status of the phone number.
        public let verified: Bool

        public static func == (lhs: PhoneNumber, rhs: PhoneNumber) -> Bool {
            lhs.phoneNumber == rhs.phoneNumber &&
                lhs.phoneId == rhs.phoneId &&
                lhs.verified == rhs.verified
        }
    }

    enum UserStatus: String, Codable {
        /// The user is an active user.
        case active
        /// The user is still in a pending status.
        case pending
    }

    struct TOTP: Codable, Equatable {
        public typealias ID = Identifier<Self, String>
        /// The id of the TOTP.
        public var id: ID { totpId }
        let totpId: ID
        /// The verification status of the TOTP.
        public let verified: Bool

        public static func == (lhs: TOTP, rhs: TOTP) -> Bool {
            lhs.totpId == rhs.totpId &&
                lhs.verified == rhs.verified
        }
    }

    struct WebAuthNRegistration: Codable, Equatable {
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

        public static func == (lhs: WebAuthNRegistration, rhs: WebAuthNRegistration) -> Bool {
            lhs.domain == rhs.domain &&
                lhs.userAgent == rhs.userAgent &&
                lhs.verified == rhs.verified &&
                lhs.webauthnRegistrationId == rhs.webauthnRegistrationId
        }
    }

    struct BiometricRegistration: Codable, Equatable {
        public typealias ID = Identifier<Self, String>
        /// The verification status of the registration.
        public let verified: Bool
        /// The id of the registration.
        public var id: ID { biometricRegistrationId }
        let biometricRegistrationId: ID

        public static func == (lhs: BiometricRegistration, rhs: BiometricRegistration) -> Bool {
            lhs.verified == rhs.verified &&
                lhs.biometricRegistrationId == rhs.biometricRegistrationId
        }
    }
}
