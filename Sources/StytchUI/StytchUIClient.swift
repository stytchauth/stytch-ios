import Combine
import StytchCore
import SwiftUI
import UIKit

/// This type serves as the entry point for all usages of the Stytch authentication UI.
public enum StytchUIClient {
    // Used to store pending reset emails so as to preserve state
    static var pendingResetEmail: String?

    // swiftformat:disable modifierOrder
    fileprivate static weak var currentController: AuthRootViewController?

    fileprivate static var config: Configuration?

    private static var cancellable: AnyCancellable?

    /// Presents Stytch's authentication UI, which will self dismiss after successful authentication. Use `StytchClient.sessions.onAuthChange` to observe auth changes.
    public static func presentController(with config: Configuration, from controller: UIViewController) {
        Self.config = config
        let rootController = AuthRootViewController(config: config)
        currentController = rootController
        setUpSessionChangeListener()
        controller.present(rootController, animated: true)
    }

    /// Use this function to handle incoming deeplinks for password resets. If presenting from SwiftUI, ensure the sheet is presented before calling this handler. You can use `StytchClient.canHandle(url:)` to determine if you should present the SwiftUI sheet before calling this handler.
    public static func handle(url: URL, from controller: UIViewController? = nil) -> Bool {
        Task { @MainActor in
            switch try await StytchClient.handle(url: url) {
            case .handled, .notHandled:
                break
            case let .manualHandlingRequired(_, token):
                let email = pendingResetEmail ?? .redactedEmail
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
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak currentController] _ in
                currentController?.dismissAuth()
                Self.cancellable = nil
            }
    }
}

public extension View {
    /// Presents Stytch's authentication UI, which will self dismiss after successful authentication. Use `StytchClient.sessions.onAuthChange` to observe auth changes.
    func authenticationSheet(isPresented: Binding<Bool>, config: StytchUIClient.Configuration) -> some View {
        sheet(isPresented: isPresented) {
            StytchUIClient.config = config
            return AuthenticationView(config: config)
                .background(Color(.background).edgesIgnoringSafeArea(.all))
        }
    }
}

public extension StytchUIClient {
    struct Configuration {
        let publicToken: String
        let navigation: Navigation?
        let products: Products
        let session: Session?

        var inputProductsEnabled: Bool {
            password != nil ||
                magicLink != nil ||
                sms != nil
        }

        var oauth: OAuth? { products.oauth }

        var password: Password? { products.password }

        var magicLink: MagicLink? { products.magicLink }

        var sms: OTP? { products.sms }

        public init(
            publicToken: String,
            navigation: Navigation? = nil,
            products: Products,
            session: Session? = nil
        ) {
            self.publicToken = publicToken
            self.navigation = navigation
            self.products = products
            self.session = session
        }

        public struct Products {
            let oauth: OAuth?
            let password: Password?
            let magicLink: MagicLink?
            let sms: OTP?

            public init(
                oauth: OAuth? = nil,
                password: Password? = nil,
                magicLink: MagicLink? = nil,
                sms: OTP? = nil
            ) {
                self.oauth = oauth
                self.password = password
                self.magicLink = magicLink
                self.sms = sms
            }
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

        public struct Navigation {
            let closeButtonStyle: CloseButtonStyle?

            /// - Parameter closeButtonStyle: Determines the type of close button used on the root view as well as its position.
            public init(closeButtonStyle: CloseButtonStyle? = .close(.right)) {
                self.closeButtonStyle = closeButtonStyle
            }

            public enum CloseButtonStyle {
                case cancel(BarButtonPosition = .right)
                case close(BarButtonPosition = .right)
                case done(BarButtonPosition = .right)
            }

            public enum BarButtonPosition {
                case left
                case right
            }
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

extension String {
    static let redactedEmail = "*****@*****"
}
