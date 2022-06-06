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

        GET["/users/me"] = UsersController.currentUser

        PUT["/users/new"] = UsersController.createUser

        GET["/hobbies"] = HobbiesController.hobbyList

        POST["/hobbies/new"] = HobbiesController.createHobby

        PUT["/hobbies/:id/update"] = HobbiesController.updateHobby
    }
}
