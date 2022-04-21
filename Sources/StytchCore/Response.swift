import Foundation

@dynamicMemberLookup
public struct Response<Wrapped: Decodable>: Decodable {
    private enum CodingKeys: String, CodingKey {
        case requestId, statusCode
    }

    public let requestId: String
    public let statusCode: UInt
    private let wrapped: Wrapped

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.requestId = try container.decode(String.self, forKey: .requestId)
        self.statusCode = try container.decode(UInt.self, forKey: .statusCode)
        self.wrapped = try .init(from: decoder)
    }

    init(requestId: String, statusCode: UInt, wrapped: Wrapped) {
        self.requestId = requestId
        self.statusCode = statusCode
        self.wrapped = wrapped
    }

    public subscript<T>(dynamicMember member: KeyPath<Wrapped, T>) -> T {
        wrapped[keyPath: member]
    }
}

/// An empty type to allow decoding the absensce of a value within various generic Decodable types
public struct EmptyDecodable: Decodable {}

/// A response type which provides only the `requestId` and `statusCode`
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

public protocol SessionResponseType {
    var userId: String { get }
    var sessionToken: String { get }
    var sessionJwt: String { get }
    var session: Session { get }
}

extension Response: SessionResponseType where Wrapped: SessionResponseType {
    public var userId: String {
        self[dynamicMember: \.userId]
    }

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
