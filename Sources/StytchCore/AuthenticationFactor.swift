import Foundation

public extension Session {
    /**
     A type which describes an factor used to authenticate a session.
     E.g. An email which was used to log in, or a phone which was used
     via SMS as an OTP second factor.
     */
    struct AuthenticationFactor: Decodable {
        private enum CodingKeys: String, CodingKey {
            case deliveryMethod
            case lastAuthenticatedAt
            case kind = "type"

            // Factors
            case emailFactor
            case phoneNumberFactor
            case googleOauthFactor
            case microsoftOauthFactor
            case appleOauthFactor
            case githubOauthFactor
            case webauthnFactor
            case authenticatorAppFactor
            case recoveryCodeFactor
        }

        private enum _DeliveryMethod: String, Decodable {
            case authenticatorApp
            case recoveryCode
            case email
            case sms
            case whatsapp
            case oauthGoogle
            case oauthApple
            case oauthGithub
            case oauthMicrosoft
            case webauthnRegistration
        }

        /// The delivery mechanism used to provide this factor.
        public let deliveryMethod: DeliveryMethod
        /// The type of factor, e.g. magic link, OTP, TOTP, etc.
        public let kind: Kind
        /// The date this factor was last used to authenticate.
        public let lastAuthenticatedAt: Date
    }
}

public extension Session.AuthenticationFactor {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lastAuthenticatedAt = try container.decode(key: .lastAuthenticatedAt)
        kind = try container.decode(key: .kind)
        let deliveryMethod: _DeliveryMethod = try container.decode(key: .deliveryMethod)

        switch deliveryMethod {
        case .authenticatorApp:
            self.deliveryMethod = .authenticatorApp(try container.decode(key: .authenticatorAppFactor))
        case .recoveryCode:
            self.deliveryMethod = .recoveryCode(try container.decode(key: .recoveryCodeFactor))
        case .email:
            self.deliveryMethod = .email(try container.decode(key: .emailFactor))
        case .sms:
            self.deliveryMethod = .sms(try container.decode(key: .phoneNumberFactor))
        case .whatsapp:
            self.deliveryMethod = .sms(try container.decode(key: .phoneNumberFactor))
        case .oauthGoogle:
            self.deliveryMethod = .oauthGoogle(try container.decode(key: .googleOauthFactor))
        case .oauthApple:
            self.deliveryMethod = .oauthApple(try container.decode(key: .appleOauthFactor))
        case .oauthGithub:
            self.deliveryMethod = .oauthGithub(try container.decode(key: .githubOauthFactor))
        case .oauthMicrosoft:
            self.deliveryMethod = .oauthMicrosoft(try container.decode(key: .microsoftOauthFactor))
        case .webauthnRegistration:
            self.deliveryMethod = .webauthnRegistration(try container.decode(key: .webauthnFactor))
        }
    }
}

public extension Session.AuthenticationFactor {
    /**
     The kind, or type, of Authentication factor, e.g. magic link, TOTP, etc.
     */
    enum Kind: String, Decodable {
        case magicLink = "magic_link" // Not a coding key, thus not converted to/from snakecase by JSONEncoder/JSONDecoder
        case otp
        case totp
        case oauth
    }

    enum DeliveryMethod {
        case authenticatorApp(AuthenticatorApp)
        case recoveryCode(RecoveryCode)
        case email(Email)
        case sms(PhoneNumber)
        case whatsapp(PhoneNumber)
        case oauthGoogle(Oauth)
        case oauthApple(Oauth)
        case oauthGithub(Oauth)
        case oauthMicrosoft(Oauth)
        case webauthnRegistration(WebAuthn)
    }

    /// Information describing an email used as an authentication factor.
    struct Email: Decodable {
        /// The id associated with this email factor.
        public let emailId: String
        /// The email address used for the authentication factor.
        public let emailAddress: String
    }

    /// Information describing a phone number used as an authentication factor.
    struct PhoneNumber: Decodable {
        /// The id associated with this phone number factor.
        public let phoneId: String
        /// The phone number used for the authentication factor.
        public let phoneNumber: String
    }

    /// Information describing Oauth used as an authentication factor.
    struct Oauth: Decodable {
        /// The id associated with this Oauth factor.
        public let id: String
        /// The id associated with the email for this Oauth factor.
        public let emailId: String
        /// The subject of the identity provider for this Oauth factor.
        public let providerSubject: String
    }

    /// Information describing a WebAuthn registration used as an authentication factor.
    struct WebAuthn: Decodable {
        /// The id associated with this WebAuthn registration.
        public let webauthnRegistrationId: String
        /// The domain associated with this WebAuthn registration.
        public let domain: URL
        /// The user agent associated with this WebAuthn registration.
        public let userAgent: String
    }

    /// Information describing a TOTP authenticator app used as an authentication factor.
    struct AuthenticatorApp: Decodable {
        /// The id associated with this TOTP factor.
        public let totpId: String
    }

    /// Information describing a TOTP recovery code used as an authentication factor.
    struct RecoveryCode: Decodable {
        /// The id associated with this recovery code factor.
        public let totpRecoveryCodeId: String
    }
}

#if DEBUG
    extension Session.AuthenticationFactor: Encodable {
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(lastAuthenticatedAt, forKey: .lastAuthenticatedAt)
            try container.encode(kind, forKey: .kind)

            switch deliveryMethod {
            case let .authenticatorApp(value):
                try container.encode(value, forKey: .authenticatorAppFactor)
                try container.encode(_DeliveryMethod.authenticatorApp.rawValue, forKey: .deliveryMethod)
            case let .recoveryCode(value):
                try container.encode(value, forKey: .recoveryCodeFactor)
                try container.encode(_DeliveryMethod.recoveryCode.rawValue, forKey: .deliveryMethod)
            case let .email(value):
                try container.encode(value, forKey: .emailFactor)
                try container.encode(_DeliveryMethod.email.rawValue, forKey: .deliveryMethod)
            case let .sms(value):
                try container.encode(value, forKey: .phoneNumberFactor)
                try container.encode(_DeliveryMethod.sms.rawValue, forKey: .deliveryMethod)
            case let .whatsapp(value):
                try container.encode(value, forKey: .phoneNumberFactor)
                try container.encode(_DeliveryMethod.whatsapp.rawValue, forKey: .deliveryMethod)
            case let .oauthGoogle(value):
                try container.encode(value, forKey: .googleOauthFactor)
                try container.encode(_DeliveryMethod.oauthGoogle.rawValue, forKey: .deliveryMethod)
            case let .oauthApple(value):
                try container.encode(value, forKey: .appleOauthFactor)
                try container.encode(_DeliveryMethod.oauthApple.rawValue, forKey: .deliveryMethod)
            case let .oauthGithub(value):
                try container.encode(value, forKey: .githubOauthFactor)
                try container.encode(_DeliveryMethod.oauthGithub.rawValue, forKey: .deliveryMethod)
            case let .oauthMicrosoft(value):
                try container.encode(value, forKey: .microsoftOauthFactor)
                try container.encode(_DeliveryMethod.oauthMicrosoft.rawValue, forKey: .deliveryMethod)
            case let .webauthnRegistration(value):
                try container.encode(value, forKey: .webauthnFactor)
                try container.encode(_DeliveryMethod.webauthnRegistration.rawValue, forKey: .deliveryMethod)
            }
        }
    }

    extension Session.AuthenticationFactor.Kind: Encodable {}
    extension Session.AuthenticationFactor.Email: Encodable {}
    extension Session.AuthenticationFactor.PhoneNumber: Encodable {}
    extension Session.AuthenticationFactor.Oauth: Encodable {}
    extension Session.AuthenticationFactor.WebAuthn: Encodable {}
    extension Session.AuthenticationFactor.AuthenticatorApp: Encodable {}
    extension Session.AuthenticationFactor.RecoveryCode: Encodable {}
#endif
