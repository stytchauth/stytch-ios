import Foundation
import Swifter
import JWTKit

struct AuthorizationController {
    let request: HttpRequest

    func currentUserId() throws -> String {
        guard
            let stytchSessionJwt = request.cookies.first(where: { $0.name == "stytch_session_jwt" }),
            let stytchJWKS = serverStorage.valueForKey(.stytchJwksKey) ??
                (try? Data(
                    contentsOf: URL(string: "https://test.stytch.com/v1/sessions/jwks")!
                        .appendingPathComponent(configuration.projectId)
                )
                ).flatMap({ try? JSONDecoder().decode(JWKS.self, from: $0) })
        else {
            throw Error(message: "Couldn't retrieve JWKS")
        }

        let payload: BasicPayload
        do {
            let signers = JWTSigners()
            try signers.use(jwks: stytchJWKS)

            payload = try signers.verify(stytchSessionJwt.value, as: BasicPayload.self)
        } catch {
            throw Error(message: "Couldn't verify token")
        }
        return payload.subject.value
    }

    struct Error: Swift.Error {
        let message: String
    }
}
