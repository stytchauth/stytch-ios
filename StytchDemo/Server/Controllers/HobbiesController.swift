import Foundation
import Swifter

struct HobbiesController: Controller {
    private static let hobbies: FileBackedStorage<Hobby> = .init(path: "hobbies")

    let request: HttpRequest

    func create() -> HttpResponse {
        AuthController(request: request).withCurrentUserId { userId in
            do {
                struct Params: Decodable {
                    let name: String
                    let favorited: Bool?
                }
                let params = try JSONDecoder().decode(Params.self, from: Data(request.body))
                let hobby = Hobby(id: .init(), userId: userId, name: params.name, favorited: params.favorited ?? false)
                try Self.hobbies.upsert(hobby)
                return .ok(.data(try JSONEncoder().encode(hobby), contentType: "application/json"))
            } catch {
                return .badRequest(nil)
            }
        }
    }

    func update() -> HttpResponse {
        AuthController(request: request).withCurrentUserId { userId in
            do {
                struct Params: Decodable {
                    let id: UUID
                    let name: String
                    let favorited: Bool
                }
                guard let id = request.params[":id"].flatMap(UUID.init(uuidString:)) else { return .badRequest(nil) }

                let params = try JSONDecoder().decode(Params.self, from: Data(request.body))

                guard params.id == id else { return .badRequest(nil) }

                if let existing = Self.hobbies.value(id: id), existing.userId != userId {
                    return .unauthorized(nil)
                }
                let hobby = Hobby(id: params.id, userId: userId, name: params.name, favorited: params.favorited)
                try Self.hobbies.upsert(hobby)
                return .ok(.data(try JSONEncoder().encode(hobby), contentType: "application/json"))
            } catch {
                return .badRequest(nil)
            }
        }
    }

    func list() -> HttpResponse {
        AuthController(request: request).withCurrentUserId { userId in
            do {
                struct Response: Encodable {
                    let userId: String
                    let hobbies: [Hobby]
                }
                // In a real application, we'd want to add an index on user id
                let response = Response(userId: userId, hobbies: Self.hobbies.values { $0.userId == userId })
                return .ok(.data(try JSONEncoder().encode(response), contentType: "application/json"))
            } catch {
                return .badRequest(nil)
            }
        }
    }

    func delete() -> HttpResponse {
        AuthController(request: request).withCurrentUserId { userId in
            guard let id = request.params[":id"].flatMap(UUID.init(uuidString:)) else { return .badRequest(nil) }
            if let existing = Self.hobbies.value(id: id), existing.userId != userId {
                return .unauthorized(nil)
            }
            do {
                try Self.hobbies.remove(id: id)
                return .ok(.json(["success": true]))
            } catch {
                return .internalServerError(nil)
            }
        }
    }
}

struct Hobby: Codable, Identifiable {
    let id: UUID
    let userId: String
    var name: String
    var favorited: Bool
}
