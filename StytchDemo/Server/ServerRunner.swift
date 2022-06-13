import Foundation
import Swifter

@main
enum ServerRunner {
    static func main() {
        if ProcessInfo.processInfo.environment["DEMO_SERVER_SCRIPT"] == nil {
            preconditionFailure("Server should be started by running `Scripts/demo-server start` from the commandline.")
        }

        let server = HttpServer()

        server.middleware.append { request in
            print("[INFO] \(request.address ?? "unknown address") -> \(request.method) -> \(request.path)")
            return nil
        }

        server.notFoundHandler = { _ in .movedPermanently("https://github.com/404") }

        mountRoutes(to: server)

        let semaphore = DispatchSemaphore(value: 0)
        do {
            try server.start(configuration.port)
            let port = try server.port()
            print("Server has started ( port = \(port) ). Try re-running and connecting via the demo app now...\nFor debugging server code, use Xcode's Debug > Attach to Process > Likely Targets > StytchDemo (Server)")

            semaphore.wait()
        } catch {
            print("Server start error: \(error)")
            semaphore.signal()
        }
    }
}
