import Foundation

public extension StytchClient.MagicLinks {
    // TODO: - document
    typealias AuthenticateResponse = Response<AuthenticateResponseData>

    // TODO: - document
    struct AuthenticateResponseData: Decodable, SessionResponseType {
        public let userId: String
        public let sessionToken: String
        public let sessionJwt: String
        public let session: Session
    }
}

#if DEBUG
    // TODO: - figure out how to ensure docs are compiled in release mode
    extension StytchClient.MagicLinks.AuthenticateResponseData: Encodable {}
#endif
