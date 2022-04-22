import Foundation

public extension StytchClient.MagicLinks {
    /// A dedicated parameters type for magic links `authenticate` calls.
    struct AuthenticateParameters: Encodable {
        private enum CodingKeys: String, CodingKey {
            case token
            case sessionDuration = "session_duration_minutes"
        }

        let token: String
        let sessionDuration: Minutes

        /**
         Initializes the parameters struct
         - Parameters:
           - token: The token extracted from the magic link.
           - sessionDuration: The duration in minutes, for the requested session.
         */
        public init(token: String, sessionDuration: Minutes) {
            self.token = token
            self.sessionDuration = sessionDuration
        }
    }
}
