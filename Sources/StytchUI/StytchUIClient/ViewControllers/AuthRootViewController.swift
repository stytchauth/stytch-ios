import AuthenticationServices
import Combine
import PhoneNumberKit
import StytchCore
import UIKit

final class AuthRootViewController: UIViewController {
    private let config: StytchUIClient.Configuration

    private var homeController: AuthHomeViewController?

    private var loadingView: UIView?
    private var activityIndicator: UIActivityIndicatorView?

    init(config: StytchUIClient.Configuration) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        render()
    }

    func handlePasswordReset(token: String, email: String?, animated: Bool = true) {
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

    func showBiometricsRegistrationIfNeeded() {
        let shouldShowBiometricRegistrationOnLogin =
            config.supportsBiometrics &&
            config.biometricsOptions.showBiometricRegistrationOnLogin &&
            StytchClient.biometrics.availability.isAvailableNoRegistration

        if shouldShowBiometricRegistrationOnLogin {
            let biometricsRegistrationViewController = BiometricsRegistrationViewController(
                state: .init(config: config),
                delegate: self
            )
            homeController?.navigationController?.pushViewController(biometricsRegistrationViewController, animated: true)
        } else {
            StytchUIClient.dismiss()
        }
    }

    @objc func dismissPresentingViewController() {
        presentingViewController?.dismiss(animated: true)
    }

    private func render() {
        let homeController = AuthHomeViewController(state: .init(config: config))

        let navigationController = UINavigationController(rootViewController: homeController)
        navigationController.navigationBar.tintColor = .primaryText
        navigationController.navigationBar.barTintColor = .background
        navigationController.navigationBar.shadowImage = .init()

        addChild(navigationController)
        view.addSubview(navigationController.view)
        navigationController.view.frame = view.bounds

        self.homeController = homeController
    }
}

extension AuthRootViewController: BiometricsRegistrationViewControllerDelegate {
    func biometricsRegistrationViewControllerDidComplete() {
        StytchUIClient.dismiss()
    }
}

extension AuthRootViewController {
    func startLoading() {
        Task { @MainActor in
            guard loadingView == nil else {
                return
            }

            let loadingView = UIView()
            // swiftlint:disable:next object_literal
            loadingView.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
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
                activityIndicator.topAnchor.constraint(equalTo: loadingView.topAnchor, constant: 300),
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
