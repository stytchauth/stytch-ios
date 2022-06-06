import Foundation
import Swifter

func mountRoutes(to server: HttpServer) {
    server.mountRoutes()
}

private extension HttpServer {
    func mountRoutes() {
        GET["/"] = { _ in .ok(.htmlBody("Hello, world!"))  }

        GET["/.well-known/apple-app-site-association"] = { _ in
                .ok(.json(["applinks":["details": [["appIDs": [configuration.appId]]]]]))
        }

        GET["/users/me"] = { UsersController(request: $0).currentUser() }

        PUT["/users/new"] = { UsersController(request: $0).createUser() }

        PUT["/hobbies/new"] = { HobbiesController(request: $0).createHobby() }
    }
}
