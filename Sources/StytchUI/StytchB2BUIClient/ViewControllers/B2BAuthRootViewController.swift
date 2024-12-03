import AuthenticationServices
import PhoneNumberKit
import StytchCore
import UIKit

final class B2BAuthRootViewController: UIViewController {
    private let configuration: StytchB2BUIClient.Configuration

    private let activityIndicator: UIActivityIndicatorView = .init(style: .large)

    private var onB2BAuthCallback: AuthCallback?

    private var homeController: B2BAuthHomeViewController?

    init(configuration: StytchB2BUIClient.Configuration, onB2BAuthCallback: AuthCallback? = nil) {
        self.configuration = configuration
        self.onB2BAuthCallback = onB2BAuthCallback
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemPink // .background

        activityIndicator.hidesWhenStopped = true

        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        render()
    }

    func handlePasswordReset(token _: String, email _: String, animated _: Bool = true) {}

    @objc func dismissAuth() {
        presentingViewController?.dismiss(animated: true)
    }

    private func render() {
        let homeController = B2BAuthHomeViewController(
            state: .init(configuration: configuration)
        )

        if let closeButton = configuration.navigation?.closeButtonStyle {
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

        self.homeController = homeController
    }

    func startMfaFlowIfNeeded() {
        homeController?.startMFAFlowIfNeeded(configuration: configuration)
    }
}
