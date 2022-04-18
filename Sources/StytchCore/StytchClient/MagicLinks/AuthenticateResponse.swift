import Foundation

public typealias AuthenticateResponse = Response<AuthenticateResponseData>

public struct AuthenticateResponseData: Decodable, SessionResponseType {
    public let userId: String
    public let sessionToken: String
    public let sessionJwt: String
    public let session: Session
}

#if DEBUG
extension AuthenticateResponseData: Encodable {}
#endif
