import AuthenticationServices
import PhoneNumberKit
import StytchCore
import UIKit

final class AuthRootViewController: UIViewController {
    private let config: StytchUIClient.Configuration

    private let activityIndicator: UIActivityIndicatorView = .init(style: .large)

    private var onAuthCallback: AuthCallback?

    init(config: StytchUIClient.Configuration, onAuthCallback: AuthCallback? = nil) {
        self.config = config
        self.onAuthCallback = onAuthCallback
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        StytchClient.configure(publicToken: config.publicToken)

        activityIndicator.hidesWhenStopped = true

        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        Task { @MainActor in
            defer { activityIndicator.stopAnimating() }
            activityIndicator.startAnimating()
            do {
                render(bootstrap: try await StytchClient._uiRouter.get(route: .bootstrap(publicToken: config.publicToken)))
            } catch {
                presentAlert(error: error)
            }
        }
    }

    func handlePasswordReset(token: String, email: String, animated: Bool = true) {
        let controller = PasswordViewController(
            state: .init(
                config: config,
                intent: .enterNewPassword(token: token),
                email: email,
                magicLinksEnabled: false
            )
        )
        navigationController?.pushViewController(controller, animated: animated)
    }

    @objc func dismissAuth() {
        presentingViewController?.dismiss(animated: true)
    }

    private func render(bootstrap: Bootstrap) {
        let homeController = AuthHomeViewController(
            state: .init(bootstrap: bootstrap, config: config)
        )
        if let closeButton = config.navigation?.closeButtonStyle {
            let keyPath: ReferenceWritableKeyPath<UIViewController, UIBarButtonItem?>
            switch closeButton.position {
            case .left:
                keyPath = \.navigationItem.leftBarButtonItem
            case .right:
                keyPath = \.navigationItem.rightBarButtonItem
            }
            homeController[keyPath: keyPath] = .init(barButtonSystemItem: closeButton.barButtonSystemItem, target: self, action: #selector(dismissAuth))
        }
        let navigationController = UINavigationController(rootViewController: homeController)
        navigationController.navigationBar.tintColor = .primaryText
        navigationController.navigationBar.barTintColor = .background
        navigationController.navigationBar.shadowImage = .init()

        addChild(navigationController)
        view.addSubview(navigationController.view)
        navigationController.view.frame = view.bounds
    }
}

struct Bootstrap: Decodable {
    let disableSdkWatermark: Bool
}

private extension StytchUIClient.Configuration.Navigation.CloseButtonStyle {
    var barButtonSystemItem: UIBarButtonItem.SystemItem {
        switch self {
        case .cancel:
            return .cancel
        case .close:
            return .close
        case .done:
            return .done
        }
    }

    var position: StytchUIClient.Configuration.Navigation.BarButtonPosition {
        switch self {
        case let .cancel(position), let .close(position), let .done(position):
            return position
        }
    }
}
