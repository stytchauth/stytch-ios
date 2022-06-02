import Foundation
import Swifter

extension HttpServer {
    func configureRoutes() {
        GET["/"] = { _ in .ok(.htmlBody("Hello, world!"))  }

        GET[".well-known/apple-app-site-association"] = { _ in
            .ok(.json(["applinks":["details": [["appIDs": [configuration.appId]]]]]))
        }
    }
}
