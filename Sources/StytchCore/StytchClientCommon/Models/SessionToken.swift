import Foundation

// TODO: include optional expiration here
/// Represents one of two kinds of tokens used to represent a session (see ``SessionToken/Kind-swift.enum``, for more info.) These tokens are used to authenticate the current user/member.
public struct SessionToken: Equatable {
    /// A type representing the different kinds of session tokens available.
    public enum Kind: CaseIterable {
        /// An token which is an opaque string, simply representing the session.
        case opaque
        /// A JWT representing the session, which contains signed and serialized information about the session.
        case jwt

        var name: String {
            switch self {
            case .opaque:
                return "stytch_session"
            case .jwt:
                return "stytch_session_jwt"
            }
        }
    }

    /// The kind of session token.
    public let kind: Kind

    /// The string value of the session token.
    public let value: String

    var name: String { kind.name }

    private init(kind: Kind, value: String) {
        self.kind = kind
        self.value = value
    }

    /// Initializes a new token and marks it as a JWT.
    public static func jwt(_ value: String) -> Self {
        .init(kind: .jwt, value: value)
    }

    /// Initializes a new token and marks it as an opaque token.
    public static func opaque(_ value: String) -> Self {
        .init(kind: .opaque, value: value)
    }
}

/// A public interface to require the caller to explicitly pass one of each type of non nil token in order to update a session.
public struct SessionTokens {
    let jwt: SessionToken
    let opaque: SessionToken

    init?(jwt: SessionToken, opaque: SessionToken) {
        if jwt.kind != .jwt, opaque.kind != .opaque {
            return nil
        }

        self.jwt = jwt
        self.opaque = opaque
    }

    func updatePersistentStorage(sessionStorage: SessionStorage) {
        sessionStorage.updatePersistentStorage(token: jwt)
        sessionStorage.updatePersistentStorage(token: opaque)
    }
}
