import Foundation
/**
 A generic type which encompasses the ``requestId`` and ``statusCode``, along with dynamic member accessors for the wrapped type.
 */
@dynamicMemberLookup
public struct Response<Wrapped: Decodable>: Decodable {
    private enum CodingKeys: String, CodingKey {
        case requestId, statusCode
    }

    /// The underlying wrapped value. It can be accessed directly or via the subscript.
    public let wrapped: Wrapped

    /// The id for the request.
    public let requestId: String

    /// The HTTP status code of the request.
    public let statusCode: UInt?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.requestId = try container.decodeIfPresent(String.self, forKey: .requestId) ?? "unknown_request_id"
        self.statusCode = try container.decodeIfPresent(UInt.self, forKey: .statusCode)
        self.wrapped = try .init(from: decoder)
    }

    init(requestId: String, statusCode: UInt, wrapped: Wrapped) {
        self.requestId = requestId
        self.statusCode = statusCode
        self.wrapped = wrapped
    }

    /// Enables dynamic member access to the wrapped type.
    /// Example usage: response[dynamicMember: \Type.property]
    public subscript<T>(dynamicMember member: KeyPath<Wrapped, T>) -> T {
        wrapped[keyPath: member]
    }
}

/// Represents the interface for basic responses.
public protocol BasicResponseType {
    var requestId: String { get }
    var statusCode: UInt? { get }
}

/// A concrete response type which provides only the `requestId` and `statusCode`.
public typealias BasicResponse = Response<EmptyCodable>

#if DEBUG
extension Response: Encodable where Wrapped: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(requestId, forKey: .requestId)
        try container.encode(statusCode, forKey: .statusCode)
        try wrapped.encode(to: encoder)
    }
}

extension Response where Wrapped == EmptyCodable {
    init(requestId: String, statusCode: UInt) {
        self.requestId = requestId
        self.statusCode = statusCode
        wrapped = .init()
    }
}
#endif

extension Response: BasicResponseType {}

extension Response: AuthenticateResponseDataType where Wrapped: AuthenticateResponseDataType {
    public var user: User { wrapped.user }
    public var sessionToken: String { wrapped.sessionToken }
    public var sessionJwt: String { wrapped.sessionJwt }
    public var session: Session { wrapped.session }
}

extension Response: B2BAuthenticateResponseDataType where Wrapped: B2BAuthenticateResponseDataType {
    public var member: Member { wrapped.member }
    public var memberSession: MemberSession { wrapped.memberSession }
    public var organization: Organization { wrapped.organization }
    public var sessionToken: String { wrapped.sessionToken }
    public var sessionJwt: String { wrapped.sessionJwt }
}
