import StytchCore
import UIKit

final class MagicLinksViewController: UIViewController {
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.layoutMargins = Constants.insets
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        view.spacing = 8
        return view
    }()

    private lazy var emailTextField: UITextField = {
        let textField: UITextField = .init(frame: .zero, primaryAction: submitAction)
        textField.borderStyle = .roundedRect
        textField.placeholder = "Email"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
        return textField
    }()

    private lazy var submitAction: UIAction = .init { [weak self] _ in
        self?.submit()
    }

    private lazy var orgIdTextField: UITextField = {
        let textField: UITextField = .init(frame: .zero, primaryAction: submitAction)
        textField.borderStyle = .roundedRect
        textField.placeholder = "Organization ID"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        return textField
    }()

    private lazy var redirectUrlTextField: UITextField = {
        let textField: UITextField = .init(frame: .zero, primaryAction: submitAction)
        textField.borderStyle = .roundedRect
        textField.placeholder = "Redirect URL"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .URL
        return textField
    }()

    private lazy var sendButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Submit"
        return .init(configuration: configuration, primaryAction: submitAction)
    }()

    private lazy var discoverySendButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Discover Send"
        return .init(configuration: configuration, primaryAction: .init { [weak self] _ in
            self?.submitDiscovery()
        })
    }()
    
    private lazy var inviteSendButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Invite Send"
        return .init(configuration: configuration, primaryAction: .init { [weak self] _ in
            self?.submitInvite()
        })
    }()

    private let defaults: UserDefaults = .standard

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Email Magic Links"

        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(orgIdTextField)
        stackView.addArrangedSubview(redirectUrlTextField)
        stackView.addArrangedSubview(sendButton)
        stackView.addArrangedSubview(discoverySendButton)
        stackView.addArrangedSubview(inviteSendButton)

        emailTextField.text = defaults.string(forKey: Constants.emailDefaultsKey)
        orgIdTextField.text = defaults.string(forKey: Constants.orgIdDefaultsKey)
        redirectUrlTextField.text = defaults.string(forKey: Constants.redirectUrlDefaultsKey) ?? "b2bworkbench://auth"
    }

    func submit() {
        guard let email = emailTextField.text, !email.isEmpty else { return }
        guard let orgId = orgIdTextField.text, !orgId.isEmpty else { return }
        guard let redirectUrl = redirectUrlTextField.text.map(URL.init(string:)) else { return }

        defaults.set(email, forKey: Constants.emailDefaultsKey)
        defaults.set(orgId, forKey: Constants.orgIdDefaultsKey)
        defaults.set(redirectUrl?.absoluteURL, forKey: Constants.redirectUrlDefaultsKey)

        Task {
            do {
                _ = try await StytchB2BClient.magicLinks.email.loginOrSignup(
                    parameters: .init(
                        organizationId: .init(rawValue: orgId),
                        email: email,
                        loginRedirectUrl: redirectUrl,
                        signupRedirectUrl: redirectUrl
                    )
                )
                presentAlertWithTitle(alertTitle: "Check your email!")
            } catch {
                presentErrorWithDescription(error: error, description: "loginOrSignup")
            }
        }
    }

    func submitDiscovery() {
        guard let email = emailTextField.text, !email.isEmpty else { return }
        guard let orgId = orgIdTextField.text, !orgId.isEmpty else { return }
        guard let redirectUrl = redirectUrlTextField.text.map(URL.init(string:)) else { return }

        defaults.set(email, forKey: Constants.emailDefaultsKey)
        defaults.set(orgId, forKey: Constants.orgIdDefaultsKey)
        defaults.set(redirectUrl?.absoluteURL, forKey: Constants.redirectUrlDefaultsKey)

        Task {
            do {
                _ = try await StytchB2BClient.magicLinks.email.discoverySend(
                    parameters: .init(
                        email: email,
                        redirectUrl: redirectUrl
                    )
                )
                presentAlertWithTitle(alertTitle: "Check your email!")
            } catch {
                presentErrorWithDescription(error: error, description: "discoverySend")
            }
        }
    }
    
    func submitInvite() {
        guard let email = emailTextField.text, !email.isEmpty else { return }
        guard let orgId = orgIdTextField.text, !orgId.isEmpty else { return }
        guard let redirectUrl = redirectUrlTextField.text.map(URL.init(string:)) else { return }

        defaults.set(email, forKey: Constants.emailDefaultsKey)
        defaults.set(orgId, forKey: Constants.orgIdDefaultsKey)
        defaults.set(redirectUrl?.absoluteURL, forKey: Constants.redirectUrlDefaultsKey)
        
        Task {
            do {
                _ = try await StytchB2BClient.magicLinks.email.inviteSend(
                    parameters: .init(
                        email: email
                    )
                )
                presentAlertWithTitle(alertTitle: "Check your email!")
            } catch {
                presentErrorWithDescription(error: error, description: "inviteSend")
            }
        }
    }
}
