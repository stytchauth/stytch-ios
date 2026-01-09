import Foundation

public typealias SessionToken = String

/// A public interface to require the caller to explicitly pass one of each type of non nil token in order to update a session.
public struct SessionTokens: Sendable {
    internal let jwt: SessionToken?
    internal let opaque: SessionToken

    /// An  initializer that requires the caller to pass a non nil opaque SessionToken and an optional jwt.
    /// - Parameters:
    ///   - jwt: An instance of `SessionToken` with a `type` of `.jwt`
    ///   - opaque: An instance of `SessionToken` with a `type` of `.opaque`
    public init(jwt: SessionToken? = nil, opaque: SessionToken) {
        self.jwt = jwt
        self.opaque = opaque
    }
}
