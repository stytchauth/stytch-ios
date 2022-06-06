import Foundation
import Swifter

struct HobbiesController: Controller {
    private static let hobbies: FileBackedStorage<Hobby> = .init(path: "hobbies")

    let request: HttpRequest

    func createHobby() -> HttpResponse {
        struct Params: Decodable {
            let name: String
            let favorited: Bool?
        }
        let currentUserId: String
        do {
            currentUserId = try AuthorizationController(request: request).currentUserId()
        } catch {
            return .unauthorized((error as? AuthorizationController.Error).map { .text($0.message) })
        }
        do {
            let params = try JSONDecoder().decode(Params.self, from: Data(request.body))
            let hobby = Hobby(id: .init(), userId: currentUserId, name: params.name, favorited: params.favorited ?? false)
            Self.hobbies.upsert(hobby)
            return .ok(.data(try JSONEncoder().encode(hobby), contentType: "application/json"))
        } catch {
            return .badRequest(nil)
        }
    }

    func hobbyList() -> HttpResponse {
        let currentUserId: String
        do {
            currentUserId = try AuthorizationController(request: request).currentUserId()
        } catch {
            return .unauthorized((error as? AuthorizationController.Error).map { .text($0.message) })
        }
        do {
            struct Response: Encodable {
                let userId: String
                let hobbies: [Hobby]
            }
            // In a real application, we'd want to add an index on user id
            let response = Response(
                userId: currentUserId,
                hobbies: Self.hobbies.values { $0.userId == currentUserId }
            )
            return .ok(.data(try JSONEncoder().encode(response), contentType: "application/json"))
        } catch {
            return .badRequest(nil)
        }

    }
}

struct Hobby: Codable, Identifiable {
    let id: UUID
    let userId: String
    var name: String
    var favorited: Bool
}
