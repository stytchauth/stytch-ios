import Foundation
import Swifter
import JWTKit

struct UsersController: Controller {
    private static let users: FileBackedStorage<User> = .init(path: "users")

    let request: HttpRequest

    func createUser() -> HttpResponse {
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

    func currentUser() -> HttpResponse {
        let currentUserId: String
        do {
            currentUserId = try AuthorizationController(request: request).currentUserId()
        } catch {
            return .unauthorized((error as? AuthorizationController.Error).map { .text($0.message) })
        }

        guard let user = user(id: currentUserId) else {
            return .notFound(.text("no current user"))
        }

        do {
            return .ok(.data(try JSONEncoder().encode(user), contentType: "application/json"))
        } catch {
            return .internalServerError(nil)
        }
    }

    func user(id: String) -> User? {
        Self.users.value(id: id)
    }

    private func upsert(id: String, update: (inout User?) -> User) throws -> String {
        var user = Self.users.value(id: id)

        try Self.users.upsert(update(&user))

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
