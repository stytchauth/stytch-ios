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

    // The UI configuration to determine which kinds of auth are needed, defaults to empty, must be overridden in configure
    static var config: Configuration = .empty

    static var onAuthCallback: AuthCallback?

    private static var cancellable: AnyCancellable?

    /// Configures the `StytchUIClient`, setting the `publicToken`, `config` and `hostUrl`.
    /// - Parameters:
    ///   - publicToken: Available via the Stytch dashboard in the `API keys` section
    ///   - config: The UI configuration to determine which kinds of auth are needed, defaults to empty
    ///   - hostUrl: Generally this is your backend's base url, where your apple-app-site-association file is hosted. This is an https url which will be used as the domain for setting session-token cookies to be sent to your servers on subsequent requests. If not passed here, no cookies will be set on your behalf.
    public static func configure(publicToken: String, config: Configuration, hostUrl: URL? = nil) {
        StytchClient.configure(publicToken: publicToken, hostUrl: hostUrl)
        Self.config = config
        loadFonts()
    }

    /// Presents Stytch's authentication UI, which will self dismiss after successful authentication. Use `StytchClient.sessions.onAuthChange` to observe auth changes.
    public static func presentController(
        controller: UIViewController,
        onAuthCallback: AuthCallback? = nil
    ) {
        Self.onAuthCallback = { response in
            Task {
                try? await EventsClient.logEvent(parameters: .init(eventName: "ui_authentication_success"))
            }
            onAuthCallback?(response)
        }
        let rootController = AuthRootViewController(config: Self.config)
        currentController = rootController
        setUpSessionChangeListener()
        controller.present(rootController, animated: true)
    }

    /// Use this function to handle incoming deeplinks for password resets.
    /// If presenting from SwiftUI, ensure the sheet is presented before calling this handler.
    /// You can use `StytchClient.canHandle(url:)` to determine if you should present the SwiftUI sheet before calling this handler.
    public static func handle(url: URL, from controller: UIViewController? = nil) -> Bool {
        Task { @MainActor in
            switch try await StytchClient.handle(url: url) {
            case let .handled(responseData):
                switch responseData {
                case let .auth(response):
                    self.onAuthCallback?(response)
                case let .oauth(response):
                    self.onAuthCallback?(response)
                }
            case .notHandled:
                break
            case let .manualHandlingRequired(_, token):
                let email = pendingResetEmail ?? .redactedEmail
                if let currentController {
                    currentController.handlePasswordReset(token: token, email: email)
                } else {
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
        cancellable = StytchClient.sessions.onSessionChange
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
        onAuthCallback: AuthCallback? = nil
    ) -> some View {
        sheet(isPresented: isPresented) {
            StytchUIClient.onAuthCallback = { response in
                Task {
                    try? await EventsClient.logEvent(parameters: .init(eventName: "ui_authentication_success"))
                }
                onAuthCallback?(response)
            }
            return AuthenticationView(config: StytchUIClient.config)
                .background(Color(.background).edgesIgnoringSafeArea(.all))
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
