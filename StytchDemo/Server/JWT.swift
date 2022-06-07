import Foundation
import JWTKit

extension InMemoryStorage.Key {
    static var stytchJwksKey: InMemoryStorage.Key<JWKS> {
        .init(
            convert: { try JSONEncoder().encode($0) },
            unconvert: { try JSONDecoder().decode(JWKS.self, from: $0) }
        )
    }
}

struct BasicPayload: JWTPayload, Equatable {
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
    }

    var subject: SubjectClaim
    var expiration: ExpirationClaim

    func verify(using _: JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
}
