import Combine
import StytchCore
import SwiftUI
import UIKit

/// This type serves as the entry point for all usages of the Stytch authentication UI.
public enum StytchUIClient {
    /// The UI configuration to determine which kinds of auth are needed, defaults to empty, must be overridden in configure
    public private(set) static var configuration = Self.Configuration.empty

    /// A publisher that emits when Stytch prebuilt UI components are ready to be dismissed.
    ///
    /// This is primarily useful when integrating the prebuilt UI with SwiftUI.
    /// The publisher fires once the user has successfully authenticated.
    ///
    /// - Publishes a `Void` value each time a dismissal event occurs.
    /// - Never completes with a failure, so subscribers can safely remain attached for the lifetime of the application.
    public static var dismissUI: AnyPublisher<Void, Never> {
        dismissUIPublisher.eraseToAnyPublisher()
    }

    private static let dismissUIPublisher = PassthroughSubject<Void, Never>()

    /// A publisher that emits errors from Stytch prebuilt UI components.
    ///
    /// These UI components make network calls to the Stytch API, and since that logic is handled internally,
    /// this publisher provides a way to observe and log those errors externally.
    ///
    /// - Publishes `Error` values for any failures that occur within Stytch prebuilt UI components.
    /// - Never completes with a failure, so subscribers can safely remain attached for the lifetime of the application.
    public static var errorPublisher: AnyPublisher<Error, Never> {
        ErrorPublisher.publisher
    }

    /// Used to store pending reset emails so as to preserve state
    static var pendingResetEmail: String?

    fileprivate static weak var currentController: AuthRootViewController?
    fileprivate static var cancellable: AnyCancellable?

    /// Configures the `StytchUIClient`
    /// - Parameters:
    ///   - configuration: Defines the configuration for `StytchConsumerUIClient`, including authentication methods, session settings,
    ///     UI customization, and user experience options. This object controls how consumers authenticate,
    ///     which authentication flows are available, and the overall look and feel of the Consumer UI.
    public static func configure(configuration: Self.Configuration) {
        StytchClient.configure(configuration: configuration.stytchClientConfiguration)
        FontLoader.loadFonts()
        Self.configuration = configuration
    }

    /// Presents Stytch's authentication UI, which will self dismiss after successful authentication. Use `StytchClient.sessions.onAuthChange` to observe auth changes.
    public static func presentController(configuration: Configuration, controller: UIViewController) {
        configure(configuration: configuration)

        let rootController = AuthRootViewController(config: Self.configuration)
        currentController = rootController
        setUpDismissAuthListener()

        let navigationController = UINavigationController(rootViewController: rootController)
        navigationController.isModalInPresentation = true // Prevents swipe-down dismissal

        controller.present(navigationController, animated: true)
    }

    /// Use this function to handle incoming deeplinks for password resets.
    /// If presenting from SwiftUI, ensure the sheet is presented before calling this handler.
    /// You can use `StytchClient.canHandle(url:)` to determine if you should present the SwiftUI sheet before calling this handler.
    public static func handle(url: URL, from controller: UIViewController? = nil) -> Bool {
        Task { @MainActor in
            switch try await StytchClient.handle(url: url) {
            case .handled:
                break
            case .notHandled:
                break
            case let .manualHandlingRequired(_, _, token):
                let email = pendingResetEmail
                if let currentController {
                    currentController.handlePasswordReset(token: token, email: email)
                } else {
                    let rootController = AuthRootViewController(config: configuration)
                    currentController = rootController
                    setUpDismissAuthListener()
                    controller?.present(UINavigationController(rootViewController: rootController), animated: true)
                    rootController.handlePasswordReset(token: token, email: email, animated: false)
                }
            }
        }
        return StytchClient.canHandle(url: url)
    }

    public static func dismiss() {
        dismissUIPublisher.send()
        cancellable = nil
        currentController?.dismissPresentingViewController()
    }

    fileprivate static func setUpDismissAuthListener() {
        cancellable = StytchClient.sessions.onSessionChange
            .receive(on: DispatchQueue.main)
            .sink { sessionInfo in
                switch sessionInfo {
                case .available:
                    EventsClient.sendAuthenticationSuccessEvent()
                    currentController?.showBiometricsRegistrationIfNeeded()
                case .unavailable:
                    break
                }
            }
    }

    static func startLoading() {
        currentController?.startLoading()
    }

    static func stopLoading() {
        currentController?.stopLoading()
    }
}

public extension View {
    /// Presents Stytch's authentication UI, which will self dismiss after successful authentication. Use `StytchClient.sessions.onSessionChange` to observe auth changes.
    func authenticationSheet(
        configuration: StytchUIClient.Configuration,
        isPresented: Binding<Bool>
    ) -> some View {
        sheet(isPresented: isPresented) {
            AuthenticationView(configuration)
                .interactiveDismissDisabled(true)
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
        let controller = AuthRootViewController(config: configuration)
        StytchUIClient.currentController = controller
        StytchUIClient.setUpDismissAuthListener()
        return UINavigationController(rootViewController: controller)
    }

    public func updateUIViewController(_: UIViewController, context _: Context) {}
}
