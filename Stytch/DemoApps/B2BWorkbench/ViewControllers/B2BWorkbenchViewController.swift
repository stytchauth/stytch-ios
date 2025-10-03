import StytchCore
import StytchUI
import UIKit

let publicToken = ""
let redirectUrl = URL(string: "b2bworkbench://auth")!
let emailDefaultsKey = "emailDefaultsKey"
let orgIdDefaultsKey = "orgIdDefaultsKey"

final class B2BWorkbenchViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()

    lazy var orgIdTextField: UITextField = .init(title: "Organization ID", primaryAction: .init { [weak self] _ in
        self?.saveOrgID()
    })

    lazy var emlButton: UIButton = .init(title: "Email Magic Links", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(MagicLinksViewController(), animated: true)
    })

    lazy var passwordsButton: UIButton = .init(title: "Passwords", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(PasswordsViewController(), animated: true)
    })

    lazy var discoveryButton: UIButton = .init(title: "Discovery", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(DiscoveryViewController(), animated: true)
    })

    lazy var ssoButton: UIButton = .init(title: "SSO", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(SSOViewController(), animated: true)
    })

    lazy var sessionsButton: UIButton = .init(title: "Sessions", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(SessionsViewController(), animated: true)
    })

    lazy var memberButton: UIButton = .init(title: "Member", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(MemberViewController(), animated: true)
    })

    lazy var organizationButton: UIButton = .init(title: "Organization", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(OrganizationViewController(), animated: true)
    })

    lazy var searchManagerButton: UIButton = .init(title: "Search Manager", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(SearchManagerViewController(), animated: true)
    })

    lazy var totpButton: UIButton = .init(title: "TOTP", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(TOTPViewController(), animated: true)
    })

    lazy var otpButton: UIButton = .init(title: "OTP", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(OTPViewController(), animated: true)
    })

    lazy var recoveryCodesButton: UIButton = .init(title: "Recovery Codes", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(RecoveryCodesViewController(), animated: true)
    })

    lazy var oauthButton: UIButton = .init(title: "OAuth", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(OAuthViewController(), animated: true)
    })

    lazy var scimButton: UIButton = .init(title: "SCIM", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(SCIMViewController(), animated: true)
    })

    lazy var b2bUIButton: UIButton = .init(title: "B2B UI", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(B2BUIViewController(), animated: true)
    })

    func saveOrgID() {
        UserDefaults.standard.set(orgIdTextField.text, forKey: orgIdDefaultsKey)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "B2B Authentication Products"

        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(orgIdTextField)
        stackView.addArrangedSubview(emlButton)
        stackView.addArrangedSubview(passwordsButton)
        stackView.addArrangedSubview(discoveryButton)
        stackView.addArrangedSubview(ssoButton)
        stackView.addArrangedSubview(sessionsButton)
        stackView.addArrangedSubview(memberButton)
        stackView.addArrangedSubview(organizationButton)
        stackView.addArrangedSubview(searchManagerButton)
        stackView.addArrangedSubview(totpButton)
        stackView.addArrangedSubview(otpButton)
        stackView.addArrangedSubview(recoveryCodesButton)
        stackView.addArrangedSubview(oauthButton)
        stackView.addArrangedSubview(scimButton)
        stackView.addArrangedSubview(b2bUIButton)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        orgIdTextField.text = organizationId
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveOrgID()
    }
}

extension B2BWorkbenchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIViewController {
    var organizationId: String? {
        UserDefaults.standard.string(forKey: orgIdDefaultsKey)
    }

    var memberId: String? {
        StytchB2BClient.member.getSync()?.id.rawValue
    }
}
