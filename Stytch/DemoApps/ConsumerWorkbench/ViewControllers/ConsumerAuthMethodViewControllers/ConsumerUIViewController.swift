import Foundation
import StytchCore
import StytchUI
import UIKit

final class ConsumerUIViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()
    lazy var showUIButton: UIButton = .init(title: "Show StytchUI", primaryAction: .init { [weak self] _ in
        self?.showStytchUI()
    })

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Stytch UI"

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

    func showStytchUI() {
        let stytchUIConfig = StytchUIClient.Configuration(
            stytchClientConfiguration: .init(publicToken: publicToken, defaultSessionDuration: 5),
            products: [.emailMagicLinks, .oauth, .passwords, .otp, .biometrics],
            navigation: Navigation(closeButtonStyle: .close(.right)),
            oauthProviders: [.apple, .thirdParty(.google)],
            passwordOptions: nil,
            magicLinkOptions: nil,
            otpOptions: .init(methods: [.sms]),
            locale: .en
        )

        StytchUIClient.presentController(configuration: stytchUIConfig, controller: self)
    }
}
