import StytchCore
import UIKit

@UIApplicationMain
final class AppDelegate: NSObject, UIApplicationDelegate {
    let networkingClient: NetworkingClient = .init()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        StytchClient.configure(publicToken: publicToken)
        networkingClient.headerProvider = {
            var headers: [String: String] = [:]
            if let token = StytchClient.sessions.sessionToken {
                headers["Authorization"] = "Bearer \(token)"
            }
            return headers
        }
        return true
    }
}
