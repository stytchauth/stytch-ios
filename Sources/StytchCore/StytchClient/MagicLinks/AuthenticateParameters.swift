import Foundation

public extension StytchClient.MagicLinks {
    struct AuthenticateParameters: Encodable {
        private enum CodingKeys: String, CodingKey {
            case token
            case sessionDuration = "session_duration_minutes"
        }

        let token: String
        let sessionDuration: Minutes

        public init(token: String, sessionDuration: Minutes) {
            self.token = token
            self.sessionDuration = sessionDuration
        }
    }
}
