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
        let publicToken = UserDefaults.standard.string(forKey: Constants.publicTokenDefaultsKey) ?? ""

        let stytchB2BUIConfig: StytchB2BUIClient.Configuration = .init(
            stytchClientConfiguration: .init(publicToken: publicToken),
            products: [.emailMagicLinks, .sso, .passwords, .oauth],
            authFlowType: .organization(slug: "no-mfa"),
            // authFlowType: .discovery,
            oauthProviders: [.init(provider: .google), .init(provider: .github)],
            navigation: Navigation(closeButtonStyle: .close(.right))
        )

        StytchB2BUIClient.presentController(configuration: stytchB2BUIConfig, controller: self)
    }
}
