import Foundation

public typealias B2BAuthenticateResponse = Response<B2BAuthenticateResponseData>

public struct B2BAuthenticateResponseData: Codable, B2BAuthenticateResponseDataType {
    public let memberSession: MemberSession
    public let member: Member
    public let sessionToken: String
    public let sessionJwt: String
}

public typealias B2BAuthenticateResponseType = BasicResponseType & B2BAuthenticateResponseDataType

public protocol B2BAuthenticateResponseDataType {
    var memberSession: MemberSession { get }
    var member: Member { get }
    var sessionToken: String { get }
    var sessionJwt: String { get }
}
