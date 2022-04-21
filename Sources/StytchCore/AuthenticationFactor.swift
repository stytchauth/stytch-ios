import Foundation

extension Session {
    public struct AuthenticationFactor: Decodable {
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

        public let deliveryMethod: DeliveryMethod
        public let kind: Kind
        public let lastAuthenticatedAt: Date

        public init(from decoder: Decoder) throws {
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
}

public extension Session.AuthenticationFactor {
    enum Kind: String, Decodable {
        case magicLink = "magic_link" // TODO: figure out why this is required
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

    struct Email: Decodable {
        public let emailId: String
        public let emailAddress: String
    }

    struct PhoneNumber: Decodable {
        public let phoneId: String
        public let phoneNumber: String
    }

    struct Oauth: Decodable {
        public let id: String
        public let emailId: String
        public let providerSubject: String
    }

    struct WebAuthn: Decodable {
        public let webauthnRegistrationId: String
        public let domain: URL
        public let userAgent: String
    }

    struct AuthenticatorApp: Decodable {
        public let totpId: String
    }

    struct RecoveryCode: Decodable {
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
            case let .recoveryCode(value):
                try container.encode(value, forKey: .recoveryCodeFactor)
            case let .email(value):
                try container.encode(value, forKey: .emailFactor)
            case let .sms(value), let .whatsapp(value):
                try container.encode(value, forKey: .phoneNumberFactor)
            case let .oauthGoogle(value):
                try container.encode(value, forKey: .googleOauthFactor)
            case let .oauthApple(value):
                try container.encode(value, forKey: .appleOauthFactor)
            case let .oauthGithub(value):
                try container.encode(value, forKey: .githubOauthFactor)
            case let .oauthMicrosoft(value):
                try container.encode(value, forKey: .microsoftOauthFactor)
            case let .webauthnRegistration(value):
                try container.encode(value, forKey: .webauthnFactor)
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
