import StytchCore
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func scene(_: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        handle(url: url)
    }

    func handle(url: URL) {
        Task {
            do {
                switch try await StytchClient.handle(url: url) {
                case let .handled(response):

                    switch response {
                    case let .auth(authResponse):
                        print("auth response: \(authResponse)")
                    case let .oauth(authResponse):
                        print("oAuth response: \(authResponse)")
                    }
                case let .manualHandlingRequired(_, _, token):
                    if let navigationController = window?.rootViewController as? UINavigationController,
                       let passwordsViewController = navigationController.viewControllers.last as? ConsumerPasswordsViewController
                    {
                        passwordsViewController.resetPassword(token: token)
                    }
                case .notHandled:
                    break
                }
            } catch {
                print("Handle URL Error: \(error.errorInfo)")
            }
        }
    }
}
