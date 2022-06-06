import Foundation
import Swifter
import JWTKit

final class StorageClient<T: Identifiable & Codable>: Codable where T.ID: Codable {
    private var storage: [T.ID: T] = [:]

    private let url: URL

    func upsert(_ value: T) {
        storage[value.id] = value
    }

    func value(id: T.ID) -> T? {
        storage[id]
    }

    init(path: String) {
        self.url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("stytch-demo/storage")
            .appendingPathComponent(path)
            .appendingPathExtension("json")
        do {
            storage = try FileManager.default.contents(atPath: url.path).map { data in
                 try JSONDecoder().decode(Self.self, from: data).storage
            } ?? [:]
        } catch {
            storage = [:]
        }
    }

    func save() throws {
        if !FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.createDirectory(
                at: url.pathExtension.isEmpty ? url : url.deletingPathExtension().deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
        }
        try JSONEncoder().encode(self).write(to: url)
    }
}

final class UsersController {
    private let users: StorageClient<User> = .init(path: "users")

    func createUser(request: HttpRequest) -> HttpResponse {
        do {
            let userParams: JSON = try JSONDecoder().decode(JSON.self, from: Data(request.body))
            guard let stytchId = userParams["stytch_id"].stringValue else { return .badRequest(nil) }
            let firstName = userParams["first_name"]?.stringValue
            let lastName = userParams["last_name"]?.stringValue

            do {
                return .ok(
                    .text(
                        try upsert(id: stytchId) { $0 ?? .init(id: stytchId, firstName: firstName ?? "", lastName: lastName ?? "") }
                    )
                )
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

        guard let user = user(id: payload.subject.value) else {
            return .notFound(.text("no current user"))
        }

        do {
            return .ok(.data(try JSONEncoder().encode(user), contentType: "application/json"))
        } catch {
            return .internalServerError(nil)
        }
    }

    private func user(id: String) -> User? {
        users.value(id: id)
    }

    private func upsert(id: String, update: (inout User?) -> User) throws -> String {
        var user = users.value(id: id)
        users.upsert(update(&user))

        try users.save()

        guard let user = user else {
            throw NSError() as Error
        }

        return user.id
    }
}

struct User: Codable, Identifiable {
    let id: String
    var firstName: String
    var lastName: String

    init(id: String, firstName: String, lastName: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
    }
}
