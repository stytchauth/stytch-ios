import Combine
import StytchCore
import UIKit

let publicTokenDefaultsKey = "StytchPublicToken"

final class ViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()

    var subscriptions: Set<AnyCancellable> = []

    lazy var publicTokenTextField: UITextField = .init(title: "Stytch Public Token", primaryAction: submitAction)

    lazy var submitButton: UIButton = .init(title: "Proceed to Auth Options", primaryAction: submitAction)

    lazy var submitAction: UIAction = .init { [weak self] _ in
        self?.submit(token: self?.publicTokenTextField.text)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(publicTokenTextField)
        stackView.addArrangedSubview(submitButton)

        let publicToken = ""
        if publicToken.isEmpty == false {
            UserDefaults.standard.set(publicToken, forKey: publicTokenDefaultsKey)
        }
        publicTokenTextField.text = UserDefaults.standard.string(forKey: publicTokenDefaultsKey)

        StytchClient.sessions.onSessionChange
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { sessionInfo in
                switch sessionInfo {
                case let .available(session, lastValidatedAtDate):
                    print("Member Session Available: \(session.expiresAt) - lastValidatedAtDate: \(lastValidatedAtDate)")
                case .unavailable:
                    print("Member Session Unavailable")
                }
            }).store(in: &subscriptions)
    }

    func submit(token: String?) {
        guard let token = token, token.isEmpty == false else {
            return
        }

        UserDefaults.standard.set(token, forKey: publicTokenDefaultsKey)

        let stytchClientConfiguration = StytchClientConfiguration(publicToken: token, defaultSessionDuration: 5)
        StytchClient.configure(configuration: stytchClientConfiguration)

        navigationController?.pushViewController(AuthHomeViewController(), animated: true)
    }
}
