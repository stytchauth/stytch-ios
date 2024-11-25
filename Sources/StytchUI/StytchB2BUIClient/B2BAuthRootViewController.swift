import AuthenticationServices
import PhoneNumberKit
import StytchCore
import UIKit

final class B2BAuthRootViewController: UIViewController {
    private let configuration: StytchB2BUIClient.Configuration

    private let activityIndicator: UIActivityIndicatorView = .init(style: .large)

    private var onB2BAuthCallback: AuthCallback?

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

    private func render() {}
}
