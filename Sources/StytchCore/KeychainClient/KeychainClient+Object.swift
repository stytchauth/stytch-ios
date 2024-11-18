import Foundation

extension KeychainClient {
    func setCodable(_ object: any Codable, for item: Item) throws {
        let encodedData = try jsonEncoder.encode(object)
        try setValueForItem(
            .init(data: encodedData, account: nil, label: nil, generic: nil, accessPolicy: nil),
            item
        )
    }
}

// This can also be done with generics, but we opted to implement it this way for the sake of explicitness in the code.
extension KeychainClient.QueryResult {
    var session: Session? {
        try? Current.jsonDecoder.decode(Session.self, from: data)
    }

    var memberSession: MemberSession? {
        try? Current.jsonDecoder.decode(MemberSession.self, from: data)
    }

    var user: User? {
        try? Current.jsonDecoder.decode(User.self, from: data)
    }

    var member: Member? {
        try? Current.jsonDecoder.decode(Member.self, from: data)
    }

    var organization: Organization? {
        try? Current.jsonDecoder.decode(Organization.self, from: data)
    }
}
