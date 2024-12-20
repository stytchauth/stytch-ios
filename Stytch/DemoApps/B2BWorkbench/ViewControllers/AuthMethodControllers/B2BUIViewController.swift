import StytchUI
import UIKit

class B2BUIViewController: UIViewController {
    let stackView = UIStackView.stytchB2BStackView()
    lazy var showUIButton: UIButton = .init(title: "Show Stytch B2B UI", primaryAction: .init { [weak self] _ in
        self?.showStytchB2BUI()
    })

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Stytch B2B UI"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(showUIButton)
    }

    func showStytchB2BUI() {
        StytchB2BUIClient.presentController(configuration: stytchB2BUIConfig, controller: self)
    }

    let stytchB2BUIConfig: StytchB2BUIClient.Configuration = .init(
        publicToken: "public-token-test-b6be6a68-d178-4a2d-ac98-9579020905bf",
        products: [.emailMagicLinks, .sso, .passwords, .oauth],
        authFlowType: .organization(slug: "no-mfa"),
        // authFlowType: .discovery,
        oauthProviders: [.init(provider: .google), .init(provider: .github)]
    )
}
