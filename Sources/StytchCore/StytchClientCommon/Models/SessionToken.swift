import Foundation

// TODO: include optional expiration here
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
