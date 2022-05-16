/// The concrete response type for `authenticate` calls.
public typealias AuthenticateResponse = Response<AuthenticateResponseData>

/// The underlying data for `authenticate` calls. See ``SessionResponseType`` for more information.
public struct AuthenticateResponseData: Codable, SessionResponseType {
    private enum CodingKeys: String, CodingKey { case user = "__user", sessionToken, sessionJwt, session }

    public let user: User?
    public let sessionToken: String
    public let sessionJwt: String
    public let session: Session
}
