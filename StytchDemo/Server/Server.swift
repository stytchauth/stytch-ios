import Foundation
import Swifter

func startServer(port: UInt16) {
    let server = HttpServer()

    mountRoutes(to: server)

    server.middleware.append { request in
        print("[INFO] \(request.address ?? "unknown address") -> \(request.method) -> \(request.path)")
        return nil
    }

    server.notFoundHandler = { _ in
        .movedPermanently("https://github.com/404")
    }

    let semaphore = DispatchSemaphore(value: 0)
    do {
        try server.start(port)
        let port = try server.port()
        print("Server has started ( port = \(port) ). Try to connect now...")

        semaphore.wait()
    } catch {
        print("Server start error: \(error)")
        semaphore.signal()
    }
}
