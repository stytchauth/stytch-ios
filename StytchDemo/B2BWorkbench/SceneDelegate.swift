import StytchCore
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func scene(_: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }

        handle(url: url)
    }

    private func handle(url: URL) {
        Task {
            do {
                switch try await StytchB2BClient.handle(url: url, sessionDuration: 60) {
                case let .handled(response):
                    // Handled via RootVC onAuthChange publisher
                    print(response)
                case .manualHandlingRequired, .notHandled:
                    break
                }
            } catch {
                print(error)
            }
        }
    }
}
