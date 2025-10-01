import Combine
import StytchCore
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var subscriptions: Set<AnyCancellable> = []

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        StytchClient.sessions.onSessionChange
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { sessionInfo in
                switch sessionInfo {
                case let .available(session, lastValidatedAtDate):
                    UIApplication.showAlert(message: "User Session Available!")
                    print("User Session Available: \(session.expiresAt) - lastValidatedAtDate: \(lastValidatedAtDate)\n")
                case .unavailable:
                    print("User Session Unavailable")
                }
            }).store(in: &subscriptions)

        return true
    }

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
