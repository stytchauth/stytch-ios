import Foundation
import Swifter
import JWTKit

final class UsersController {
    private static let usersCsvUrl = FileManager.default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("stytch-demo")
        .appendingPathComponent("users")
        .appendingPathExtension("csv")

    private var users: CSV<User> = {
        if FileManager.default.fileExists(atPath: usersCsvUrl.path) {
            do {
                return try .init(url: usersCsvUrl)
            } catch {
                return .init()
            }
        } else {
            return .init()
        }
    }()

    func createUser(request: HttpRequest) -> HttpResponse {
        do {
            let userParams: JSON = try JSONDecoder().decode(JSON.self, from: Data(request.body))
            guard let stytchId = userParams["stytch_id"].stringValue else { return .badRequest(nil) }
            let firstName = userParams["first_name"]?.stringValue
            let lastName = userParams["last_name"]?.stringValue

            do {
                let id = try upsert(stytchId: stytchId) { user in
                    user ?? .new(stytchId: stytchId, firstName: firstName ?? "", lastName: lastName ?? "")
                }
                return .ok(.text(id.uuidString))
            } catch {
                return .internalServerError(nil)
            }
        } catch {
            return .badRequest(nil)
        }
    }

    func currentUser(request: HttpRequest) -> HttpResponse {
        guard
            let stytchSessionJwt = request.cookies.first(where: { $0.name == "stytch_session_jwt" }),
            let stytchJWKS = serverStorage.valueForKey(.stytchJwksKey) ??
                (try? Data(
                    contentsOf: URL(string: "https://test.stytch.com/v1/sessions/jwks")!
                        .appendingPathComponent(configuration.projectId)
                )
                ).flatMap({ try? JSONDecoder().decode(JWKS.self, from: $0) })
        else {
            return .unauthorized(.text("couldn't get keys"))
        }

        let payload: TestPayload
        do {
            let signers = JWTSigners()
            try signers.use(jwks: stytchJWKS)

            payload = try signers.verify(stytchSessionJwt.value, as: TestPayload.self)
        } catch {
            return .unauthorized(.text("couldn't verify token"))
        }

        guard let user = user(stytchId: payload.subject.value) else {
            return .notFound(.text("no current user"))
        }

        do {
            return .ok(.data(try JSONEncoder().encode(user), contentType: "application/json"))
        } catch {
            return .internalServerError(nil)
        }
    }

    private func user(stytchId: String) -> User? {
        users.first { $0.stytchId == stytchId }
    }

    private func upsert(stytchId: String, update: (inout User?) -> User) throws -> UUID {
        var user: User?

        if let index = users.firstIndex(where: { $0.stytchId == stytchId }) {
            user = users[index]
            users[index] = update(&user)
        } else {
            users.append(update(&user))
        }

        try users.save(to: Self.usersCsvUrl)

        guard let user = user else {
            throw NSError() as Error
        }

        return user.id
    }
}

struct User: Codable {
    let id: UUID
    let stytchId: String
    var firstName: String
    var lastName: String

    private init(id: UUID, stytchId: String, firstName: String, lastName: String) {
        self.id = id
        self.stytchId = stytchId
        self.firstName = firstName
        self.lastName = lastName
    }

    static func new(stytchId: String, firstName: String, lastName: String) -> Self {
        .init(id: .init(), stytchId: stytchId, firstName: firstName, lastName: lastName)
    }
}

extension User: CSVRow {
    static var headerNames: [String] { ["id", "stytchId", "firstName", "firstName"] }

    static func from(_ strings: inout [String]) throws -> Self {
        guard let id = UUID(uuidString: strings.removeFirst()) else { throw Error() }
        let stytchId = strings.removeFirst()
        let firstName = strings.removeFirst()
        let lastName = strings.removeFirst()

        return .init(id: id, stytchId: stytchId, firstName: firstName, lastName: lastName)
    }

    static func encodedRow(_ value: Self, encodeColumn: (String) -> EncodedColumn) -> [EncodedColumn] {
        [
            encodeColumn(value.id.uuidString),
            encodeColumn(value.stytchId),
            encodeColumn(value.firstName),
            encodeColumn(String(value.lastName))
        ]
    }

    struct Error: Swift.Error {}
}
