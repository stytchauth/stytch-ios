import AuthenticationServices
import PhoneNumberKit
import StytchCore
import UIKit

final class B2BAuthRootViewController: UIViewController {
    private let configuration: StytchB2BUIClient.Configuration

    private var onB2BAuthCallback: AuthCallback?

    private var homeController: B2BAuthHomeViewController?

    private var loadingView: UIView?
    private var activityIndicator: UIActivityIndicatorView?

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
        render()
    }

    func handlePasswordReset(token: String, email: String, animated: Bool = true) {
        let state = PasswordResetState(configuration: configuration, token: token, email: email)
        navigationController?.pushViewController(PasswordResetViewController(state: state), animated: animated)
    }

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

    func startDiscoveryFlowIfNeeded() {
        homeController?.startDiscoveryFlowIfNeeded(configuration: configuration)
    }
}

extension B2BAuthRootViewController {
    func startLoading() {
        Task { @MainActor in
            guard loadingView == nil else {
                return
            }

            let loadingView = UIView()
            // swiftlint:disable:next object_literal
            loadingView.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
            loadingView.translatesAutoresizingMaskIntoConstraints = false

            let activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.startAnimating()

            loadingView.addSubview(activityIndicator)
            view.addSubview(loadingView)

            NSLayoutConstraint.activate([
                loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                loadingView.topAnchor.constraint(equalTo: view.topAnchor),
                loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor),
            ])

            self.loadingView = loadingView
            self.activityIndicator = activityIndicator
        }
    }

    func stopLoading() {
        Task { @MainActor in
            loadingView?.removeFromSuperview()
            loadingView = nil
            activityIndicator?.stopAnimating()
            activityIndicator = nil
        }
    }
}
