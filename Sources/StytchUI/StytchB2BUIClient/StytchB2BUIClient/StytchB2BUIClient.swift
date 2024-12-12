import Combine
import StytchCore
import SwiftUI
import UIKit

// swiftlint:disable modifier_order

public typealias B2BAuthenticateCallback = () -> Void

public enum StytchB2BUIClient {
    // The UI configuration to determine which kinds of auth are needed, defaults to empty, must be overridden in configure
    static var configuration: Configuration = .empty
    static var onB2BAuthCallback: B2BAuthenticateCallback?
    private static var cancellable: AnyCancellable?
    fileprivate weak static var currentController: B2BAuthRootViewController?

    /// Configures the `StytchB2BUIClient`.
    /// - Parameters:
    ///   - configuration: The UI configuration to determine which kinds of auth are needed, defaults to empty
    public static func configure(configuration: Configuration) {
        StytchB2BClient.configure(publicToken: configuration.publicToken, hostUrl: configuration.hostUrl)
        FontLoader.loadFonts()
        Self.configuration = configuration
    }

    /// Presents Stytch's authentication UI, which will self dismiss after successful authentication. Use `StytchClient.sessions.onAuthChange` to observe auth changes.
    public static func presentController(
        controller: UIViewController,
        onB2BAuthCallback: B2BAuthenticateCallback? = nil
    ) {
        Self.onB2BAuthCallback = {
            Task {
                try? await EventsClient.logEvent(parameters: .init(eventName: "ui_authentication_success"))
            }
            onB2BAuthCallback?()
        }
        let rootController = B2BAuthRootViewController(configuration: Self.configuration)
        currentController = rootController
        Self.setUpDismissAuthListener()
        let navigationController = UINavigationController(rootViewController: rootController)
        controller.present(navigationController, animated: true)
    }

    /// Use this function to handle incoming deeplinks for password resets.
    /// If presenting from SwiftUI, ensure the sheet is presented before calling this handler.
    /// You can use `StytchB2BClient.canHandle(url:)` to determine if you should present the SwiftUI sheet before calling this handler.
    public static func handle(url: URL, from controller: UIViewController? = nil) -> Bool {
        startLoading()
        print(controller as Any)
        Task { @MainActor in
            switch try await StytchB2BClient.handle(url: url, sessionDuration: configuration.sessionDurationMinutes) {
            case let .handled(responseData):
                switch responseData {
                case let .mfauth(response):
                    B2BAuthenticationManager.handlePrimaryMFAReponse(b2bMFAAuthenticateResponse: response)
                    currentController?.startMfaFlowIfNeeded()
                case let .mfaOAuth(response):
                    B2BAuthenticationManager.handlePrimaryMFAReponse(b2bMFAAuthenticateResponse: response)
                    currentController?.startMfaFlowIfNeeded()
                case let .discovery(response):
                    MemberManager.updateMemberEmailAddress(response.emailAddress)
                    DiscoveryManager.updateDiscoveredOrganizations(newDiscoveredOrganizations: response.discoveredOrganizations)
                    currentController?.startDiscoveryFlowIfNeeded()
                case let .discoveryOauth(response):
                    MemberManager.updateMemberEmailAddress(response.emailAddress)
                    DiscoveryManager.updateDiscoveredOrganizations(newDiscoveredOrganizations: response.discoveredOrganizations)
                    currentController?.startDiscoveryFlowIfNeeded()
                }
            case .notHandled:
                break
            case let .manualHandlingRequired(_, token):
                let email = MemberManager.emailAddress ?? .redactedEmail
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
        }
        return StytchB2BClient.canHandle(url: url)
    }

    static func setUpDismissAuthListener() {
        cancellable = B2BAuthenticationManager.dismissUI
            .receive(on: DispatchQueue.main)
            .sink { [weak currentController] in
                currentController?.dismissAuth()
                Self.cancellable = nil
                Self.reset()
            }
    }

    static func reset() {
        B2BAuthenticationManager.reset()
        DiscoveryManager.reset()
        MemberManager.reset()
        OrganizationManager.reset()
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
        isPresented: Binding<Bool>,
        onB2BAuthCallback: B2BAuthenticateCallback? = nil
    ) -> some View {
        sheet(isPresented: isPresented) {
            StytchB2BUIClient.onB2BAuthCallback = {
                Task {
                    try? await EventsClient.logEvent(parameters: .init(eventName: "ui_authentication_success"))
                }
                onB2BAuthCallback?()
            }
            return B2BAuthenticationView()
                .background(Color(.background).edgesIgnoringSafeArea(.all))
        }
    }
}

struct B2BAuthenticationView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController

    func makeUIViewController(context _: Context) -> UIViewController {
        let controller = B2BAuthRootViewController(configuration: StytchB2BUIClient.configuration)
        StytchB2BUIClient.currentController = controller
        StytchB2BUIClient.setUpDismissAuthListener()
        return UINavigationController(rootViewController: controller)
    }

    func updateUIViewController(_: UIViewController, context _: Context) {}
}
