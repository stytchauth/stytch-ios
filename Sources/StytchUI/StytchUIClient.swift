import Combine
import StytchCore
import UIKit

public enum StytchUIClient {
    static var pendingResetEmail: String?

    fileprivate static weak var currentController: AuthRootViewController?

    private static var config: Configuration?

    private static var cancellable: AnyCancellable?

    public static func presentController(with config: Configuration, from controller: UIViewController) {
        Self.config = config
        let rootController = AuthRootViewController(config: config)
        currentController = rootController
        setUpSessionChangeListener()
        controller.present(rootController, animated: true)
    }

    public static func handle(url: URL, from controller: UIViewController? = nil) -> Bool {
        Task { @MainActor in
            switch try await StytchClient.handle(url: url) {
            case .handled, .notHandled:
                break
            case let .manualHandlingRequired(_, token):
                let email = pendingResetEmail ?? "*****@*****"
                if let currentController {
                    currentController.handlePasswordReset(token: token, email: email)
                } else if let config {
                    let rootController = AuthRootViewController(config: config)
                    currentController = rootController
                    setUpSessionChangeListener()
                    controller?.present(rootController, animated: true)
                    rootController.handlePasswordReset(token: token, email: email, animated: false)
                }
            }
        }
        return StytchClient.canHandle(url: url)
    }

    static func setUpSessionChangeListener() {
        cancellable = StytchClient.sessions.onAuthChange
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak currentController] token in
                currentController?.presentingViewController?.dismiss(animated: true)
            })
    }
}

public extension StytchUIClient {
    struct Configuration {
        let publicToken: String
        let oauth: OAuth?
        let input: Input?

        public init(publicToken: String, oauth: OAuth?, input: Input?) {
            self.publicToken = publicToken
            self.oauth = oauth
            self.input = input
        }

        public enum Input {
            case magicLink(sms: Bool)
            case password(sms: Bool)
            case magicLinkAndPassword(sms: Bool)
            case smsOnly
        }
        public struct OAuth {
            let providers: [Provider]

            public init(providers: [Provider]) {
                self.providers = providers
            }

            public enum Provider {
                case apple
                case thirdParty(StytchClient.OAuth.ThirdParty.Provider)
            }
        }
    }
}

import SwiftUI

extension View {
    public func authenticationSheet(isPresented: Binding<Bool>, config: StytchUIClient.Configuration) -> some View {
        sheet(isPresented: isPresented) {
            AuthenticationView(config: config)
        }
    }
}

struct AuthenticationView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController

    let config: StytchUIClient.Configuration

    init(config: StytchUIClient.Configuration) {
        self.config = config
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = AuthRootViewController(config: config)
        StytchUIClient.currentController = controller
        StytchUIClient.setUpSessionChangeListener()
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
