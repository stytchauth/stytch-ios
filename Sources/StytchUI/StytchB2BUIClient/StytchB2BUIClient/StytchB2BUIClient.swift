import Combine
import StytchCore
import SwiftUI
import UIKit

public enum StytchB2BUIClient {
    // The UI configuration to determine which kinds of auth are needed, defaults to empty, must be overridden in configure
    public private(set) static var configuration = Self.Configuration.empty

    /// A publisher that emits when Stytch prebuilt UI components are ready to be dismissed.
    ///
    /// This is primarily useful when integrating the prebuilt UI with SwiftUI.
    /// The publisher typically fires once the user has successfully authenticated.
    /// In cases where TOTP is being set up, it will not emit until the user has saved their recovery codes.
    ///
    /// - Publishes a `Void` value each time a dismissal event occurs.
    /// - Never completes with a failure, so subscribers can safely remain attached for the lifetime of the application.
    public static var dismissUI: AnyPublisher<Void, Never> {
        B2BAuthenticationManager.dismissUI
    }

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

    fileprivate static var cancellable: AnyCancellable?
    fileprivate static weak var currentController: B2BAuthRootViewController?

    /// Configures the `StytchB2BUIClient`.
    /// - Parameters:
    ///   - configuration: Defines the configuration for `StytchB2BUIClient`, including authentication methods, session settings,
    ///     UI customization, and organizational options. This object controls how users authenticate,
    ///     which authentication flows are available, and the overall user experience within the B2B UI.
    public static func configure(configuration: Self.Configuration) {
        reset()
        StytchB2BClient.configure(configuration: configuration.stytchClientConfiguration)
        FontLoader.loadFonts()
        Self.configuration = configuration
    }

    /// Presents Stytch's authentication UI, which will self dismiss after successful authentication. Use `StytchClient.sessions.onAuthChange` to observe auth changes.
    public static func presentController(
        configuration: Configuration,
        controller: UIViewController
    ) {
        configure(configuration: configuration)

        let rootController = B2BAuthRootViewController(configuration: configuration)
        currentController = rootController
        Self.setUpDismissAuthListener()

        let navigationController = UINavigationController(rootViewController: rootController)
        navigationController.isModalInPresentation = true // Prevents swipe-down dismissal

        controller.present(navigationController, animated: true)
    }

    /// Use this function to handle incoming deeplinks for password resets.
    /// If presenting from SwiftUI, ensure the sheet is presented before calling this handler.
    /// You can use `StytchB2BClient.canHandle(url:)` to determine if you should present the SwiftUI sheet before calling this handler.
    public static func handle(url: URL, from controller: UIViewController? = nil) -> Bool {
        startLoading()
        currentController?.popToRootViewController(animated: false)
        Task { @MainActor in
            do {
                switch try await StytchB2BClient.handle(url: url) {
                case let .handled(responseData):
                    switch responseData {
                    case let .mfauth(response):
                        B2BAuthenticationManager.handlePrimaryMFAReponse(b2bMFAAuthenticateResponse: response)
                        currentController?.startMfaFlowIfNeeded()
                    case let .mfaOAuth(response):
                        B2BAuthenticationManager.handlePrimaryMFAReponse(b2bMFAAuthenticateResponse: response)
                        currentController?.startMfaFlowIfNeeded()
                    case let .discovery(response), let .discoveryOauth(response):
                        MemberManager.updateMemberEmailAddress(response.emailAddress)
                        DiscoveryManager.updateDiscoveredOrganizations(newDiscoveredOrganizations: response.discoveredOrganizations)
                        currentController?.startDiscoveryFlowIfNeeded()
                    }
                case .notHandled:
                    break
                case let .manualHandlingRequired(_, _, token):
                    let email = MemberManager.emailAddress
                    if let currentController {
                        currentController.handlePasswordReset(token: token, email: email)
                    } else {
                        let rootController = B2BAuthRootViewController(configuration: configuration)
                        currentController = rootController
                        setUpDismissAuthListener()
                        controller?.present(UINavigationController(rootViewController: rootController), animated: true)
                        rootController.handlePasswordReset(token: token, email: email, animated: false)
                    }
                }
                stopLoading()
            } catch {
                ErrorPublisher.publishError(error)
                currentController?.showErrorScreen()
                stopLoading()
            }
        }
        return StytchB2BClient.canHandle(url: url)
    }

    public static func dismiss() {
        currentController?.dismissAuth()
        cancellable = nil
        reset()
    }

    fileprivate static func setUpDismissAuthListener() {
        cancellable = dismissUI
            .receive(on: DispatchQueue.main)
            .sink {
                dismiss()
            }
    }

    private static func reset() {
        B2BAuthenticationManager.reset()
        DiscoveryManager.reset()
        MemberManager.reset()
        OrganizationManager.reset()
        SSODiscoveryManager.reset()
    }

    static func startLoading() {
        currentController?.startLoading()
    }

    static func stopLoading() {
        currentController?.stopLoading()
    }
}

public extension View {
    /// Presents Stytch's authentication UI, which will self dismiss after successful authentication. Use `StytchB2BClient.sessions.onMemberSessionChange` to observe auth changes.
    func b2bAuthenticationSheet(
        configuration: StytchB2BUIClient.Configuration,
        isPresented: Binding<Bool>
    ) -> some View {
        sheet(isPresented: isPresented) {
            B2BAuthenticationView(configuration)
                .interactiveDismissDisabled(true)
                .background(Color(.background).edgesIgnoringSafeArea(.all))
        }
    }
}

public struct B2BAuthenticationView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIViewController

    public let configuration: StytchB2BUIClient.Configuration

    public init(_ configuration: StytchB2BUIClient.Configuration) {
        self.configuration = configuration
    }

    public func makeUIViewController(context _: Context) -> UIViewController {
        StytchB2BUIClient.configure(configuration: configuration)
        let controller = B2BAuthRootViewController(configuration: configuration)
        StytchB2BUIClient.currentController = controller
        StytchB2BUIClient.setUpDismissAuthListener()
        return UINavigationController(rootViewController: controller)
    }

    public func updateUIViewController(_: UIViewController, context _: Context) {}
}
