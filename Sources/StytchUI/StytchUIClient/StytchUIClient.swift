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
    static var configuration: Configuration = .empty

    static var onAuthCallback: AuthCallback?

    private static var cancellable: AnyCancellable?

    /// Configures the `StytchUIClient`
    /// - Parameters:
    ///   - configuration: The UI configuration to determine which kinds of auth are needed, defaults to empty
    static func configure(configuration: Configuration) {
        StytchClient.configure(publicToken: configuration.publicToken, hostUrl: configuration.hostUrl, dfppaDomain: configuration.dfppaDomain)
        Self.configuration = configuration
        FontLoader.loadFonts()
    }

    /// Presents Stytch's authentication UI, which will self dismiss after successful authentication. Use `StytchClient.sessions.onAuthChange` to observe auth changes.
    public static func presentController(
        configuration: Configuration,
        controller: UIViewController,
        onAuthCallback: AuthCallback? = nil
    ) {
        configure(configuration: configuration)
        Self.onAuthCallback = { response in
            Task {
                try? await EventsClient.logEvent(parameters: .init(eventName: "ui_authentication_success"))
            }
            onAuthCallback?(response)
        }
        let rootController = AuthRootViewController(config: Self.configuration)
        currentController = rootController
        setUpSessionChangeListener()
        let navigationController = UINavigationController(rootViewController: rootController)
        controller.present(navigationController, animated: true)
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
            case let .manualHandlingRequired(_, _, token):
                let email = pendingResetEmail
                if let currentController {
                    currentController.handlePasswordReset(token: token, email: email)
                } else {
                    let rootController = AuthRootViewController(config: configuration)
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
            .receive(on: DispatchQueue.main)
            .sink { [weak currentController] sessionInfo in
                switch sessionInfo {
                case .available:
                    currentController?.dismissAuth()
                    Self.cancellable = nil
                case .unavailable:
                    break
                }
            }
    }
}

public extension View {
    /// Presents Stytch's authentication UI, which will self dismiss after successful authentication. Use `StytchClient.sessions.onSessionChange` to observe auth changes.
    func authenticationSheet(
        configuration: StytchUIClient.Configuration,
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
            return AuthenticationView(configuration)
                .background(Color(.background).edgesIgnoringSafeArea(.all))
        }
    }
}

public struct AuthenticationView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIViewController

    public let configuration: StytchUIClient.Configuration

    public init(_ configuration: StytchUIClient.Configuration) {
        self.configuration = configuration
    }

    public func makeUIViewController(context _: Context) -> UIViewController {
        StytchUIClient.configure(configuration: configuration)
        let controller = AuthRootViewController(config: StytchUIClient.configuration)
        StytchUIClient.currentController = controller
        StytchUIClient.setUpSessionChangeListener()
        return UINavigationController(rootViewController: controller)
    }

    public func updateUIViewController(_: UIViewController, context _: Context) {}
}
