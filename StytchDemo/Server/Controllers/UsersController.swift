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
            let firstName = userParams["first_name"]?.stringValue ?? ""
            let lastName = userParams["last_name"]?.stringValue ?? ""

            do {
                let user: User = .init(id: stytchId, firstName: firstName, lastName: lastName)
                try Self.users.upsert(user)
                return .ok(.text(user.id))
            } catch {
                return .internalServerError(nil)
            }
        } catch {
            return .badRequest(nil)
        }
    }

    func currentUser() -> HttpResponse {
        AuthController(request: request).withCurrentUserId { userId in
            guard let user = user(id: userId) else {
                return .notFound(.text("No current user"))
            }
            do {
                return .ok(.data(try JSONEncoder().encode(user), contentType: "application/json"))
            } catch {
                return .internalServerError(nil)
            }
        }
    }

    func user(id: String) -> User? {
        Self.users.value(id: id)
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
