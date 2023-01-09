import Foundation

public extension Session {
    /**
     A type which describes an factor used to authenticate a session.
     E.g. An email which was used to log in, or a phone which was used
     via SMS as an OTP second factor.
     */
    struct AuthenticationFactor: Hashable {
        private enum CodingKeys: String, CodingKey {
            case lastAuthenticatedAt
            case kind = "type"
        }

        /// The underlying data representing this factor. Includes additional information about the specific factor ids and values.
        public let rawData: JSON
        /// The type of factor, e.g. magic link, OTP, TOTP, etc.
        public let kind: String
        /// The date this factor was last used to authenticate.
        public let lastAuthenticatedAt: Date
    }
}

extension Session.AuthenticationFactor: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lastAuthenticatedAt = try container.decode(key: .lastAuthenticatedAt)
        kind = try container.decode(key: .kind)
        rawData = try .init(from: decoder)
    }
}

public extension Session.AuthenticationFactor {
    /// If the factor is an email factor this will be the associated email address value, else nil
    var emailAddress: String? {
        rawData["email_factor"]["email_address"]?.stringValue
    }

    /// If the factor is a phone factor (SMS/WhatsApp delivery method) this will be the associated phone number value, else nil
    var phoneNumber: String? {
        rawData["phone_factor"]["phone_number"]?.stringValue
    }

    var deliveryMethod: String? {
        rawData["delivery_method"]?.stringValue
    }
}

#if DEBUG
extension Session.AuthenticationFactor: Encodable {
    public func encode(to encoder: Encoder) throws {
        try rawData.encode(to: encoder)
    }
}
#endif
