import Foundation

public extension StytchClient.MagicLinks {
    /// The concrete response type for magic links `authenticate` calls.
    typealias AuthenticateResponse = Response<AuthenticateResponseData>

    /// The underlying data for magic links `authenticate` calls. See ``SessionResponseType`` for more information.
    struct AuthenticateResponseData: Decodable, SessionResponseType {
        public let userId: String
        public let sessionToken: String
        public let sessionJwt: String
        public let session: Session
    }
}

#if DEBUG
    extension StytchClient.MagicLinks.AuthenticateResponseData: Encodable {}
#endif
