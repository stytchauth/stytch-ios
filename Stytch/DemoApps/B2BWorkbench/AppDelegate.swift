import Combine
import StytchCore
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var subscriptions: Set<AnyCancellable> = []

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        StytchB2BClient.member.onMemberChange
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { memberInfo in
                switch memberInfo {
                case let .available(member, lastValidatedAtDate):
                    UIApplication.showAlert(message: "Member Session Available!")
                    print("Member Available: \(member.name) - lastValidatedAtDate: \(lastValidatedAtDate)")
                case .unavailable:
                    print("Member Unavailable")
                }
            }).store(in: &subscriptions)

        StytchB2BClient.sessions.onMemberSessionChange
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { sessionInfo in
                switch sessionInfo {
                case let .available(session, lastValidatedAtDate):
                    print("Member Session Available: \(session.expiresAt) - lastValidatedAtDate: \(lastValidatedAtDate)")
                case .unavailable:
                    print("Member Session Unavailable")
                }
            }).store(in: &subscriptions)

        return true
    }

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
