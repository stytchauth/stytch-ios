import UIKit

final class AuthHomeViewController: UIViewController {
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.layoutMargins = Constants.insets
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        view.spacing = 8
        return view
    }()

    private lazy var emlButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Email Magic Links"
        return .init(configuration: configuration, primaryAction: .init { [weak navigationController] _ in
            navigationController?.pushViewController(MagicLinksViewController(), animated: true)
        })
    }()

    private lazy var passwordsButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Passwords"
        return .init(configuration: configuration, primaryAction: .init { [weak navigationController] _ in
            navigationController?.pushViewController(PasswordsViewController(), animated: true)
        })
    }()

    private lazy var sessionsButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Sessions"
        return .init(configuration: configuration, primaryAction: .init { [weak navigationController] _ in
            navigationController?.pushViewController(SessionsViewController(), animated: true)
        })
    }()

    private lazy var memberButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Member"
        return .init(configuration: configuration, primaryAction: .init { [weak navigationController] _ in
            navigationController?.pushViewController(MemberViewController(), animated: true)
        })
    }()

    private lazy var organizationButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Organization"
        return .init(configuration: configuration, primaryAction: .init { [weak navigationController] _ in
            navigationController?.pushViewController(OrganizationViewController(), animated: true)
        })
    }()

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
        stackView.addArrangedSubview(sessionsButton)
        stackView.addArrangedSubview(memberButton)
        stackView.addArrangedSubview(organizationButton)
    }
}
