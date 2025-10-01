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
                switch try await StytchB2BClient.handle(url: url) {
                case let .handled(response):
                    // Handled via RootVC onAuthChange publisher
                    switch response {
                    case let .discovery(authResponse):
                        print("discovery auth response: \(authResponse)")
                    case let .discoveryOauth(authResponse):
                        print("discovery oauth response: \(authResponse)")
                    case let .mfauth(authResponse):
                        print("mfa response: \(authResponse)")
                    case let .mfaOAuth(authResponse):
                        print("mfaOAuth response: \(authResponse)")
                    }
                case let .manualHandlingRequired(tokenType, redirectType, token):
                    if let navigationController = window?.rootViewController as? UINavigationController,
                       let passwordsViewController = navigationController.viewControllers.last as? PasswordsViewController
                    {
                        if tokenType == .multiTenantPasswords {
                            passwordsViewController.resetPassword(token: token, passwordDiscovery: false)
                        } else if tokenType == .discovery, redirectType == .resetPassword {
                            passwordsViewController.resetPassword(token: token, passwordDiscovery: true)
                        }
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
