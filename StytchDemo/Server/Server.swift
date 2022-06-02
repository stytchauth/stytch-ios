import Foundation
import Swifter

func startServer() {
    let server = HttpServer()

    server.configureRoutes()

    server.middleware.append { request in
        print("[INFO] \(request.address ?? "unknown address") -> \(request.method) -> \(request.path)")
        return nil
    }

    server.notFoundHandler = { _ in
        return .movedPermanently("https://github.com/404")
    }

    let semaphore = DispatchSemaphore(value: 0)
    do {
        try server.start()
        let port = try server.port()
        print("Server has started ( port = \(port) ). Try to connect now...")

        semaphore.wait()
    } catch {
        print("Server start error: \(error)")
        semaphore.signal()
    }
}
