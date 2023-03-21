import StytchCore
import UIKit

@UIApplicationMain
final class AppDelegate: NSObject, UIApplicationDelegate {
    private let stytchPublicToken = "your-public-token"
    private let hostUrl = URL(string: "https://your-backend.com")!

    private var session: Session? {
        didSet {
            // set up or tear down flow
        }
    }

    private let deeplinkCoordinator: DeeplinkCoordinator

    override init() {
        let stytchHandler = StytchDeeplinkHandler()

        deeplinkCoordinator = .init(handlers: stytchHandler)

        super.init()

        stytchHandler.onResetPassword = { token in
            // Pass along to reset token flow
        }

        stytchHandler.onSessionChange = { [weak self] response in
            self?.session = response.session
        }
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        StytchClient.configure(publicToken: stytchPublicToken, hostUrl: hostUrl)
        return true
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        // Handle universal links
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
            return deeplinkCoordinator.handle(url: url)
        }
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        // Handle custom scheme deeplinks
        return deeplinkCoordinator.handle(url: url)
    }
}

protocol DeeplinkHandler {
    func canHandle(url: URL) -> Bool
    func handle(url: URL)
}

final class DeeplinkCoordinator {
    let handlers: [DeeplinkHandler]

    init(handlers: DeeplinkHandler...) {
        self.handlers = handlers
    }

    func handle(url: URL) -> Bool {
        guard let handler = handlers.first(where: { $0.canHandle(url: url) }) else {
            return false
        }
        handler.handle(url: url)
        return true
    }
}

final class StytchDeeplinkHandler: DeeplinkHandler, @unchecked Sendable {
    var onSessionChange: (AuthenticateResponseType) -> Void = { _ in }
    var onResetPassword: (_ token: String) -> Void = { _ in }

    func canHandle(url: URL) -> Bool {
        StytchClient.canHandle(url: url)
    }

    func handle(url: URL) {
        Task {
            do {
                switch try await StytchClient.handle(url: url) {
                case let .manualHandlingRequired(tokenType, token):
                    guard case .passwordReset = tokenType else {
                        // shouldn't happen, log an error
                        return
                    }
                    onResetPassword(token)
                case let .handled(authResponse):
                    onSessionChange(authResponse)
                case .notHandled:
                    // shouldn't happen since canHandle(url:) was checked, log an error
                    break
                }
            } catch {
                // Handle errors
            }
        }
    }
}
