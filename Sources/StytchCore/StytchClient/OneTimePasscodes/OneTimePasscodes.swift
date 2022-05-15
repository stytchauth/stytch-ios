import SwiftUI
public extension StytchClient {
    struct OneTimePasscodes {
        let pathContext: Endpoint.Path = "otps"

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        func authenticate(parameters: AuthenticateParameters, completion: @escaping Completion<AuthenticateResponse>) {
            StytchClient.post(
                to: .init(path: pathContext.appendingPathComponent("authenticate")),
                parameters: parameters,
                completion: completion
            )
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        public func loginOrCreate(parameters: LoginOrCreateParameters, completion: @escaping Completion<LoginOrCreateResponse>) {
            StytchClient.post(
                to: .init(
                    path: pathContext
                        .appendingPathComponent(parameters.deliveryMethod.pathComponent.rawValue)
                        .appendingPathComponent("login_or_create")
                ),
                parameters: parameters,
                completion: completion
            )
        }
    }
}

public extension StytchClient {
    static var otps: OneTimePasscodes { .init() }
}

public extension StytchClient.OneTimePasscodes {
    struct AuthenticateParameters: Encodable {
        private enum CodingKeys: String, CodingKey { case code = "token", methodId, sessionDuration = "session_duration_minutes" }

        let code: String
        let methodId: String
        let sessionDuration: Minutes

        public init(code: String, methodId: String, sessionDuration: Minutes) {
            self.code = code
            self.methodId = methodId
            self.sessionDuration = sessionDuration
        }
    }
}

public extension StytchClient.OneTimePasscodes {
    typealias LoginOrCreateResponse = Response<LoginOrCreateResponseData>

    struct LoginOrCreateParameters: Encodable {
        private enum CodingKeys: String, CodingKey { case phoneNumber, email, expiration = "expiration_minutes" }

        let deliveryMethod: DeliveryMethod
        let expiration: Minutes

        /// - Parameters:
        ///   - deliveryMethod: The mechanism used to deliver the one-time passcode.
        ///   - expiration: Set the expiration for the one-time passcode, in minutes. The minimum expiration is 1 minute and the maximum is 10 minutes. The default expiration is 2 minutes.
        public init(deliveryMethod: DeliveryMethod, expiration: Minutes = 2) {
            self.deliveryMethod = deliveryMethod
            self.expiration = expiration
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(expiration, forKey: .expiration)
            switch deliveryMethod {
            case let .sms(value), let .whatsapp(value):
                try container.encode(value, forKey: .phoneNumber)
            case let .email(value):
                try container.encode(value, forKey: .email)
            }
        }
    }

    struct LoginOrCreateResponseData: Codable {
        public let methodId: String
    }
}

public extension StytchClient.OneTimePasscodes.LoginOrCreateParameters {
    enum DeliveryMethod {
        /// The phone number of the user to send a one-time passcode. The phone number should be in E.164 format (i.e. +1XXXXXXXXXX)
        case sms(phoneNumber: String)
        /// The phone number of the user to send a one-time passcode. The phone number should be in E.164 format (i.e. +1XXXXXXXXXX)

        case whatsapp(phoneNumber: String)
        /// The email address of the user to send the one-time passcode to.
        case email(String)

        var pathComponent: Endpoint.Path {
            switch self {
            case .sms:
                return "sms"
            case .whatsapp:
                return "whatsapp"
            case .email:
                return "email"
            }
        }
    }
}
