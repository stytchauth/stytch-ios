import Foundation
import JWTKit
import Swifter

struct AuthController: Controller {
    let request: HttpRequest

    func withCurrentUserId(_ task: (String) -> HttpResponse) -> HttpResponse {
        guard
            let stytchSessionJwt = request.cookies.first(where: { $0.name == "stytch_session_jwt" }),
            let stytchJWKS = memoryStorage.valueForKey(.stytchJwksKey) ??
            (
                try? Data(
                    contentsOf: URL(string: "https://test.stytch.com/v1/sessions/jwks")!
                        .appendingPathComponent(configuration.projectId)
                )
            ).flatMap({ try? JSONDecoder().decode(JWKS.self, from: $0) })
        else {
            return .unauthorized(.text("Couldn't retrieve JWKS"))
        }

        do {
            let signers = JWTSigners()
            try signers.use(jwks: stytchJWKS)

            return task(try signers.verify(stytchSessionJwt.value, as: BasicPayload.self).subject.value)
        } catch {
            return .unauthorized(.text("Couldn't verify token"))
        }
    }
}
