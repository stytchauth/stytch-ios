import Foundation
/**
 A generic type which encompasses the ``requestId`` and ``statusCode``, along with dynamic member accessors for the wrapped type.
 */
@dynamicMemberLookup
public struct Response<Wrapped: Decodable>: Decodable {
    private enum CodingKeys: String, CodingKey {
        case requestId, statusCode
    }

    /// The id for the request.
    public let requestId: String
    /// The HTTP status code of the request.
    public let statusCode: UInt
    private let wrapped: Wrapped

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.requestId = try container.decode(key: .requestId)
        self.statusCode = try container.decode(key: .statusCode)
        self.wrapped = try .init(from: decoder)
    }

    init(requestId: String, statusCode: UInt, wrapped: Wrapped) {
        self.requestId = requestId
        self.statusCode = statusCode
        self.wrapped = wrapped
    }

    /// Enables dynamic member access to the wrapped type.
    public subscript<T>(dynamicMember member: KeyPath<Wrapped, T>) -> T {
        wrapped[keyPath: member]
    }
}

/// An empty type to allow decoding the absence of a value within various generic Decodable types.
public struct EmptyDecodable: Decodable {}

/// A concrete response type which provides only the `requestId` and `statusCode`.
public typealias BasicResponse = Response<EmptyDecodable>

#if DEBUG
extension Response: Encodable where Wrapped: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(requestId, forKey: .requestId)
        try container.encode(statusCode, forKey: .statusCode)
        try wrapped.encode(to: encoder)
    }
}

extension EmptyDecodable: Encodable {}

extension Response where Wrapped == EmptyDecodable {
    init(requestId: String, statusCode: UInt) {
        self.requestId = requestId
        self.statusCode = statusCode
        wrapped = .init()
    }
}
#endif

/**
 An interface for the various response types which include ``Session`` information.
 */
public protocol SessionResponseType {
    /**
     The opaque token for the session. Can be used by your server to verify the
     validity of your session by confirming with Stytch's servers on each request.
     */
    var sessionToken: String { get }
    /**
     The JWT for the session. Can be used by your server to verify the validity of
     your session either by checking the data included in the JWT, or by verifying
     with Stytch's servers as needed.
     */
    var sessionJwt: String { get }
    /**
     The ``Session`` object, which includes information about the session's validity, expiry, factors associated with this session, and more.
     */
    var session: Session { get }
}

extension Response: SessionResponseType where Wrapped: SessionResponseType {
    public var userId: String { session.userId }

    public var sessionToken: String {
        self[dynamicMember: \.sessionToken]
    }

    public var sessionJwt: String {
        self[dynamicMember: \.sessionJwt]
    }

    public var session: Session {
        self[dynamicMember: \.session]
    }
}
