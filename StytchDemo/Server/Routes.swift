import Foundation
import Swifter

extension ServerRunner {
    static func mountRoutes(to server: HttpServer) {
        server.mountRoutes()
    }
}

private extension HttpServer {
    func mountRoutes() {
        GET["/"] = { _ in .ok(.htmlBody("Hello, world!")) }

        GET["/.well-known/apple-app-site-association"] = { _ in
            .ok(.json(["applinks": ["details": [["appIDs": [configuration.appleAppId]]]]]))
        }

        GET["/hobbies"] = HobbiesController.list

        POST["/hobbies/new"] = HobbiesController.create

        PUT["/hobbies/:id"] = HobbiesController.update

        DELETE["hobbies/:id"] = HobbiesController.delete
    }
}
