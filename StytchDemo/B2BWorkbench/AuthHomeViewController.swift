import UIKit

final class AuthHomeViewController: UIViewController {
    let stackView = UIStackView.stytchB2BStackView()

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

        stackView.addArrangedSubview(emlButton)
        stackView.addArrangedSubview(passwordsButton)
        stackView.addArrangedSubview(discoveryButton)
        stackView.addArrangedSubview(ssoButton)
        stackView.addArrangedSubview(sessionsButton)
        stackView.addArrangedSubview(memberButton)
        stackView.addArrangedSubview(organizationButton)
    }
}
