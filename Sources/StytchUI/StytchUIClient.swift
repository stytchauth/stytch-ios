import Combine
import StytchCore
import UIKit

public enum StytchUIClient {
    static var pendingResetEmail: String?

    // swiftformat:disable modifierOrder
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
            .sink { [weak currentController] _ in
                currentController?.presentingViewController?.dismiss(animated: true)
            }
    }
}

public extension StytchUIClient {
    struct Configuration {
        let publicToken: String
        let products: [Product]
        let session: Session?

        var inputProductsEnabled: Bool {
            password != nil ||
                magicLink != nil ||
                sms != nil
        }

        var oauth: OAuth? {
            products.firstAs { product in
                guard case let .oauth(config) = product else { return nil }
                return config
            }
        }

        var password: Password? {
            products.firstAs { product in
                guard case let .password(config) = product else { return nil }
                return config
            }
        }

        var magicLink: MagicLink? {
            products.firstAs { product in
                guard case let .magicLink(config) = product else { return nil }
                return config
            }
        }

        var sms: OTP? {
            products.firstAs { product in
                guard case let .sms(config) = product else { return nil }
                return config
            }
        }

        public init(
            publicToken: String,
            products: [Product],
            session: Session? = nil
        ) {
            self.publicToken = publicToken
            self.products = products
            self.session = session
        }

        public enum Product {
            case oauth(OAuth)
            case password(Password = .init())
            case magicLink(MagicLink = .init())
            case sms(OTP = .init())
        }

        public struct OAuth {
            let providers: [Provider]
            let loginRedirectUrl: URL
            let signupRedirectUrl: URL

            public init(providers: [Provider], loginRedirectUrl: URL, signupRedirectUrl: URL) {
                self.providers = providers
                self.loginRedirectUrl = loginRedirectUrl
                self.signupRedirectUrl = signupRedirectUrl
            }

            public enum Provider {
                case apple
                case thirdParty(StytchClient.OAuth.ThirdParty.Provider)
            }
        }

        public struct MagicLink {
            let loginMagicLinkUrl: URL?
            let loginExpiration: Minutes?
            let loginTemplateId: String?
            let signupMagicLinkUrl: URL?
            let signupExpiration: Minutes?
            let signupTemplateId: String?

            public init(
                loginMagicLinkUrl: URL? = nil,
                loginExpiration: Minutes? = nil,
                loginTemplateId: String? = nil,
                signupMagicLinkUrl: URL? = nil,
                signupExpiration: Minutes? = nil,
                signupTemplateId: String? = nil
            ) {
                self.loginMagicLinkUrl = loginMagicLinkUrl
                self.loginExpiration = loginExpiration
                self.loginTemplateId = loginTemplateId
                self.signupMagicLinkUrl = signupMagicLinkUrl
                self.signupExpiration = signupExpiration
                self.signupTemplateId = signupTemplateId
            }
        }

        public struct Password {
            let loginURL: URL?
            let loginExpiration: Minutes?
            let resetPasswordURL: URL?
            let resetPasswordExpiration: Minutes?
            let resetPasswordTemplateId: String?

            public init(
                loginURL: URL? = nil,
                loginExpiration: Minutes? = nil,
                resetPasswordURL: URL? = nil,
                resetPasswordExpiration: Minutes? = nil,
                resetPasswordTemplateId: String? = nil
            ) {
                self.loginURL = loginURL
                self.loginExpiration = loginExpiration
                self.resetPasswordURL = resetPasswordURL
                self.resetPasswordExpiration = resetPasswordExpiration
                self.resetPasswordTemplateId = resetPasswordTemplateId
            }
        }

        public struct OTP {
            let expiration: Minutes?

            public init(
                expiration: Minutes? = nil
            ) {
                self.expiration = expiration
            }
        }

        public struct Session {
            let sessionDuration: Minutes?

            public init(sessionDuration: Minutes? = nil) {
                self.sessionDuration = sessionDuration
            }
        }
    }
}

import SwiftUI

public extension View {
    func authenticationSheet(isPresented: Binding<Bool>, config: StytchUIClient.Configuration) -> some View {
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

    func makeUIViewController(context _: Context) -> UIViewController {
        let controller = AuthRootViewController(config: config)
        StytchUIClient.currentController = controller
        StytchUIClient.setUpSessionChangeListener()
        return controller
    }

    func updateUIViewController(_: UIViewController, context _: Context) {}
}
