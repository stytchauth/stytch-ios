public extension StytchClient {
    /// One-time passcodes can be sent via email, phone number, or WhatsApp. One-time passcodes allow for a quick and seamless login experience on their own, or can layer on top of another login product like Email magic links to provide extra security as a multi-factor authentication (MFA) method.
    struct OneTimePasscodes {
        let router: NetworkingRouter<OneTimePasscodesRoute>

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps Stytch's OTP [sms/login_or_create](https://stytch.com/docs/api/log-in-or-create-user-by-sms), [whatsapp/login_or_create](https://stytch.com/docs/api/whatsapp-login-or-create), and [email/login_or_create](https://stytch.com/docs/api/log-in-or-create-user-by-email-otp) endpoints. Requests a one-time passcode for a user to log in or create an account depending on the presence and/or status current account.
        public func loginOrCreate(parameters: LoginOrCreateParameters) async throws -> LoginOrCreateResponse {
            try await router.post(
                to: .loginOrCreate(parameters.deliveryMethod),
                parameters: parameters
            )
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps the OTP [authenticate](https://stytch.com/docs/api/authenticate-otp) API endpoint which validates the one-time code passed in. If this method succeeds, the user will be logged in, granted an active session, and the session cookies will be minted and stored in `HTTPCookieStorage.shared`.
        public func authenticate(parameters: AuthenticateParameters) async throws -> AuthenticateResponse {
            try await router.post(
                to: .authenticate,
                parameters: parameters
            )
        }
    }
}

public extension StytchClient {
    /// The interface for interacting with one-time-passcodes products.
    static var otps: OneTimePasscodes { .init(router: router.scopedRouter(BaseRoute.otps)) }
}

public extension StytchClient.OneTimePasscodes {
    /// The dedicated parameters type for OTP `authenticate` calls.
    struct AuthenticateParameters: Encodable {
        private enum CodingKeys: String, CodingKey { case code = "token", methodId, sessionDuration = "session_duration_minutes" }

        let code: String
        let methodId: String
        let sessionDuration: Minutes

        /// - Parameters:
        ///   - code: The one-time passcode
        ///   - methodId: The methodId captured upon requesting the OTP.
        ///   - sessionDuration: The duration, in minutes, of the requested session. Defaults to 30 minutes.
        public init(code: String, methodId: String, sessionDuration: Minutes = .defaultSessionDuration) {
            self.code = code
            self.methodId = methodId
            self.sessionDuration = sessionDuration
        }
    }
}

public extension StytchClient.OneTimePasscodes {
    /// The dedicated parameters type for OTP `loginOrCreate` calls.
    struct LoginOrCreateParameters: Encodable {
        private enum CodingKeys: String, CodingKey { case phoneNumber, email, expiration = "expiration_minutes" }

        let deliveryMethod: DeliveryMethod
        let expiration: Minutes?

        /// - Parameters:
        ///   - deliveryMethod: The mechanism used to deliver the one-time passcode.
        ///   - expiration: Set the expiration for the one-time passcode, in minutes. The minimum expiration is 1 minute and the maximum is 10 minutes. The default expiration is 2 minutes.
        public init(deliveryMethod: DeliveryMethod, expiration: Minutes? = nil) {
            self.deliveryMethod = deliveryMethod
            self.expiration = expiration
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(expiration, forKey: .expiration)
            switch deliveryMethod {
            case let .sms(value), let .whatsapp(value):
                try container.encode(value, forKey: .phoneNumber)
            case let .email(value):
                try container.encode(value, forKey: .email)
            }
        }
    }
}

public extension StytchClient.OneTimePasscodes {
    /// The concrete response type for OTP `loginOrCreate` calls.
    typealias LoginOrCreateResponse = Response<LoginOrCreateResponseData>

    /// The underlying data for OTP `loginOrCreate` responses.
    struct LoginOrCreateResponseData: Codable {
        public let methodId: String
    }
}

public extension StytchClient.OneTimePasscodes.LoginOrCreateParameters {
    /// The mechanism use to deliver one-time passcodes.
    enum DeliveryMethod {
        /// The phone number of the user to send a one-time passcode. The phone number should be in E.164 format (i.e. +1XXXXXXXXXX)
        case sms(phoneNumber: String)
        /// The phone number of the user to send a one-time passcode. The phone number should be in E.164 format (i.e. +1XXXXXXXXXX)
        case whatsapp(phoneNumber: String)
        /// The email address of the user to send the one-time passcode to.
        case email(String)

        var path: Path {
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
