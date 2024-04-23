import Combine
import StytchCore
import SwiftUI
import UIKit

public typealias AuthCallback = (AuthenticateResponseType) -> Void

/// This type serves as the entry point for all usages of the Stytch authentication UI.
public enum StytchUIClient {
    // Used to store pending reset emails so as to preserve state
    static var pendingResetEmail: String?

    // swiftformat:disable modifierOrder
    fileprivate static weak var currentController: AuthRootViewController?

    static var config: Configuration?

    static var onAuthCallback: AuthCallback?

    private static var cancellable: AnyCancellable?

    /// Presents Stytch's authentication UI, which will self dismiss after successful authentication. Use `StytchClient.sessions.onAuthChange` to observe auth changes.
    public static func presentController(
        with config: Configuration,
        from controller: UIViewController,
        onAuthCallback: AuthCallback? = nil
    ) {
        Self.config = config
        Self.onAuthCallback = { response in
            Task {
                try? await StytchClient.events.logEvent(parameters: .init(eventName: "ui_authentication_success"))
            }
            onAuthCallback?(response)
        }
        let rootController = AuthRootViewController(config: config)
        currentController = rootController
        setUpSessionChangeListener()
        controller.present(rootController, animated: true)
    }

    /// Use this function to handle incoming deeplinks for password resets. If presenting from SwiftUI, ensure the sheet is presented before calling this handler. You can use `StytchClient.canHandle(url:)` to determine if you should present the SwiftUI sheet before calling this handler.
    public static func handle(url: URL, from controller: UIViewController? = nil) -> Bool {
        Task { @MainActor in
            switch try await StytchClient.handle(url: url) {
            case let .handled(response):
                self.onAuthCallback?(response)
            case .notHandled:
                break
            case let .manualHandlingRequired(_, token):
                let email = pendingResetEmail ?? .redactedEmail
                if let currentController {
                    currentController.handlePasswordReset(token: token, email: email)
                } else if let config {
                    let rootController = AuthRootViewController(config: config)
                    currentController = rootController
                    setUpSessionChangeListener()
                    controller?.present(UINavigationController(rootViewController: rootController), animated: true)
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
    func authenticationSheet(
        isPresented: Binding<Bool>,
        config: StytchUIClient.Configuration,
        onAuthCallback: AuthCallback? = nil
    ) -> some View {
        sheet(isPresented: isPresented) {
            StytchUIClient.config = config
            StytchUIClient.onAuthCallback = { response in
                Task {
                    try? await StytchClient.events.logEvent(parameters: .init(eventName: "ui_authentication_success"))
                }
                onAuthCallback?(response)
            }
            return AuthenticationView(config: config)
                .background(Color(.background).edgesIgnoringSafeArea(.all))
        }
    }
}

public extension StytchUIClient {
    /// Configures the Stytch UI client
    struct Configuration: Codable {
        let publicToken: String
        let navigation: Navigation?
        let products: Products
        let session: Session?
        let theme: StytchTheme

        var inputProductsEnabled: Bool {
            password != nil ||
                magicLink != nil ||
                otp != nil
        }

        var oauth: OAuth? { products.oauth }

        var password: Password? { products.password }

        var magicLink: MagicLink? { products.magicLink }

        var otp: OTP? { products.otp }

        public init(
            publicToken: String,
            navigation: Navigation? = nil,
            products: Products,
            session: Session? = nil,
            theme: StytchTheme = StytchTheme()
        ) {
            self.publicToken = publicToken
            self.navigation = navigation
            self.products = products
            self.session = session
            self.theme = theme
        }

        /// A struct representing the configuration options for all supported and enabled products. To enable a product, provide it's configuration options. To disable a product, leave it's configuration `nil`
        public struct Products: Codable {
            let oauth: OAuth?
            let password: Password?
            let magicLink: MagicLink?
            let otp: OTP?

            public init(
                oauth: OAuth? = nil,
                password: Password? = nil,
                magicLink: MagicLink? = nil,
                otp: OTP? = nil
            ) {
                self.oauth = oauth
                self.password = password
                self.magicLink = magicLink
                self.otp = otp
            }
        }

        /// A struct defining the configuration of the OAuth product. It accepts a list of Providers as well as signup and login redirect URLs
        public struct OAuth: Codable {
            let providers: [Provider]
            let loginRedirectUrl: URL
            let signupRedirectUrl: URL

            public init(providers: [Provider], loginRedirectUrl: URL, signupRedirectUrl: URL) {
                self.providers = providers
                self.loginRedirectUrl = loginRedirectUrl
                self.signupRedirectUrl = signupRedirectUrl
            }

            public enum Provider: Codable {
                case apple
                case thirdParty(StytchClient.OAuth.ThirdParty.Provider)
            }
        }

        /// A struct defining the configuration of the Email Magic Links product. If you do not provide a value for a property in this configuration, it will use the defaults that are configured in your Stytch Dashboard
        /// `loginMagicLinkUrl` is the URL served to returning users logging in
        /// `loginExpiration` is the number of minutes that a login link is valid for
        /// `loginTemplateId` is the ID of the custom login template you have created in your Stytch Dashboard
        /// `signupMagicLinkUrl` is the URL served to new users signing up
        /// `signupExpiration` is the number of minutes that a signup link is valid for
        /// `signupTemplateId` is the ID of the custom signup template you have created in your Stytch Dashboard
        public struct MagicLink: Codable {
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

        /// A struct defining the configuration of the Passwords product. If you do not provide a value for a property in this configuration, it will use the defaults that are configured in your Stytch Dashboard
        /// `loginUrl` is the URL served to returning users who are logging in
        /// `loginExpiration` is the number of minutes that a login link is valid for
        /// `resetPasswordURL` is the URL served to users who must reset their password
        /// `resetPasswordExpiration` is the number of minutes that a reset password link is valid for
        /// `resetPasswordTemplateId` is the ID of the custom password reset template you have created in your Stytch Dashboard
        public struct Password: Codable {
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

        /// A struct defining the configuration of the One Time Passcode (OTP) product. Leaving the optional fields `nil` will use the defaults from your Stytch Dashboard
        /// `methods` specifies the OTP methods that should be enabled
        /// `expiration` is the number of minutes that an OTP code is valid for
        /// `loginTemplateId` is the ID of the custom login template you have created in your Stytch Dashboard. This is only used for Email OTP.
        /// `signupTemplateId` is the ID of the custom signup template you have created in your Stytch Dashboard. This is only used for Email OTP.
        public struct OTP: Codable {
            let methods: Set<OTPMethod>
            let expiration: Minutes?
            let loginTemplateId: String?
            let signupTemplateId: String?

            public init(
                methods: Set<OTPMethod>,
                expiration: Minutes? = nil,
                loginTemplateId: String? = nil,
                signupTemplateId: String? = nil
            ) {
                self.methods = methods
                self.expiration = expiration
                self.loginTemplateId = loginTemplateId
                self.signupTemplateId = signupTemplateId
            }
        }

        /// The OTP methods that are available
        public enum OTPMethod: Codable {
            case sms
            case email
            case whatsapp
        }

        /// A struct defining the configuration of our sessions product. This configuration is used for all authentication flows.
        /// `sessionDuration` The length of time a new session should be valid for. This must be less than or equal to the maximum time allowed in your Stytch Dashboard
        public struct Session: Codable {
            let sessionDuration: Minutes?

            public init(sessionDuration: Minutes? = nil) {
                self.sessionDuration = sessionDuration
            }
        }

        public struct Navigation: Codable {
            let closeButtonStyle: CloseButtonStyle?

            /// - Parameter closeButtonStyle: Determines the type of close button used on the root view as well as its position.
            public init(closeButtonStyle: CloseButtonStyle? = .close(.right)) {
                self.closeButtonStyle = closeButtonStyle
            }

            public enum CloseButtonStyle: Codable {
                case cancel(BarButtonPosition = .right)
                case close(BarButtonPosition = .right)
                case done(BarButtonPosition = .right)
            }

            public enum BarButtonPosition: Codable {
                case left
                case right
            }
        }
    }
}

struct AuthenticationView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController

    let config: StytchUIClient.Configuration

    func makeUIViewController(context _: Context) -> UIViewController {
        let controller = AuthRootViewController(config: config)
        StytchUIClient.currentController = controller
        StytchUIClient.setUpSessionChangeListener()
        return UINavigationController(rootViewController: controller)
    }

    func updateUIViewController(_: UIViewController, context _: Context) {}
}

extension String {
    static let redactedEmail = "*****@*****"
}
