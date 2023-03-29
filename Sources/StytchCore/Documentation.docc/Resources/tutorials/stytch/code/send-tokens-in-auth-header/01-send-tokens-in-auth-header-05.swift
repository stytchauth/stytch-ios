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
        networkingClient.headerProvider = { [:] }
        return true
    }
}
