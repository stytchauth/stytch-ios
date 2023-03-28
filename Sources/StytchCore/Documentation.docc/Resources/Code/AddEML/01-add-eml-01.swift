import StytchCore
import UIKit

@UIApplicationMain
final class AppDelegate: NSObject, UIApplicationDelegate {
    ...

    override init() {
        ...

        super.init()
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        // Handle universal links
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        // Handle custom scheme deeplinks
        return true
    }
}
