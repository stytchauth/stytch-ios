import UIKit

@UIApplicationMain
final class AppDelegate: NSObject, UIApplicationDelegate {
    private var session: Session? {
        didSet {
            // set up or tear down flow
        }
    }

    private let deeplinkCoordinator: DeeplinkCoordinator

    override init() {
        deeplinkCoordinator = .init(handlers: [])

        super.init()
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
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
