import Combine
import StytchCore
import UIKit

let publicToken = ""
let redirectUrl = URL(string: "workbench://auth")!
let emailDefaultsKey = "emailDefaultsKey"

final class ConsumerWorkbenchViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()

    lazy var magicLinksButton: UIButton = .init(title: "Email Magic Links", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(ConsumerMagicLinksViewController(), animated: true)
    })

    lazy var passwordsButton: UIButton = .init(title: "Passwords", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(ConsumerPasswordsViewController(), animated: true)
    })

    lazy var otpButton: UIButton = .init(title: "OTP", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(ConsumerOTPViewController(), animated: true)
    })

    lazy var biometricsButton: UIButton = .init(title: "Biometrics", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(ConsumerBiometricsViewController(), animated: true)
    })

    lazy var totpButton: UIButton = .init(title: "TOTP", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(ConsumerTOTPViewController(), animated: true)
    })

    lazy var sessionsButton: UIButton = .init(title: "Sessions", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(ConsumerSessionsViewController(), animated: true)
    })

    lazy var userButton: UIButton = .init(title: "User", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(ConsumerUserViewController(), animated: true)
    })

    lazy var oauthButton: UIButton = .init(title: "OAuth", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(ConsumerOAuthViewController(), animated: true)
    })

    lazy var consumerUIButton: UIButton = .init(title: "Consumer UI", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(ConsumerUIViewController(), animated: true)
    })

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Consumer Workbench"

        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(magicLinksButton)
        stackView.addArrangedSubview(passwordsButton)
        stackView.addArrangedSubview(otpButton)
        stackView.addArrangedSubview(biometricsButton)
        stackView.addArrangedSubview(totpButton)
        stackView.addArrangedSubview(sessionsButton)
        stackView.addArrangedSubview(userButton)
        stackView.addArrangedSubview(oauthButton)
        stackView.addArrangedSubview(consumerUIButton)

        let stytchClientConfiguration = StytchClientConfiguration(publicToken: publicToken, defaultSessionDuration: 5)
        StytchClient.configure(configuration: stytchClientConfiguration)
    }
}
