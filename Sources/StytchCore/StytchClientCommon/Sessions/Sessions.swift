public enum Sessions {
    /// The dedicated parameters type for sessions `authenticate` calls.
    public struct AuthenticateParameters: Encodable {
        private enum CodingKeys: String, CodingKey {
            case sessionDuration = "sessionDurationMinutes"
        }

        let sessionDuration: Minutes?

        /// - Parameter sessionDuration: The duration, in minutes, of the requested session.
        /// If included, this value must be a minimum of 5 and may not exceed the maximum session duration minutes value set in the SDK Configuration page of the Stytch dashboard.
        /// Defaults to nil, leaving the original session expiration intact.
        public init(sessionDuration: Minutes? = nil) {
            self.sessionDuration = sessionDuration
        }
    }

    /// The dedicated parameters type for session `revoke` calls.
    public struct RevokeParameters {
        let forceClear: Bool

        /// - Parameter forceClear: In the event of an error received from the network, setting this value to true will ensure the local session state is cleared.
        public init(forceClear: Bool = false) {
            self.forceClear = forceClear
        }
    }
}
