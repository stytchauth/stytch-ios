import Combine
import StytchCore
import UIKit

final class RootViewController: UIViewController {
    let stackView = UIStackView.stytchB2BStackView()
    var subscriptions: Set<AnyCancellable> = []

    lazy var publicTokenTextField: UITextField = .init(title: "Stytch Public Token", primaryAction: submitAction)

    lazy var submitButton: UIButton = .init(title: "Proceed to Auth Options", primaryAction: submitAction)

    lazy var memberIdLabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

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

        stackView.addArrangedSubview(memberIdLabel)
        stackView.addArrangedSubview(publicTokenTextField)
        stackView.addArrangedSubview(submitButton)

        memberIdLabel.preferredMaxLayoutWidth = view.bounds.width - 2 * Constants.padding
        memberIdLabel.isHidden = true

        let publicToken = ""
        if publicToken.isEmpty == false {
            UserDefaults.standard.set(publicToken, forKey: Constants.publicTokenDefaultsKey)
        }
        publicTokenTextField.text = UserDefaults.standard.string(forKey: Constants.publicTokenDefaultsKey)

        StytchB2BClient.member.onMemberChange
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] memberInfo in
                switch memberInfo {
                case let .available(member, lastValidatedAtDate):
                    print("Member Available: \(member.name) - lastValidatedAtDate: \(lastValidatedAtDate)")
                    self?.memberIdLabel.text = "Welcome, \(member.id.rawValue)!"
                case .unavailable:
                    print("Member Unavailable")
                    self?.memberIdLabel.text = "Logged out"
                }
            }).store(in: &subscriptions)

        StytchB2BClient.sessions.onMemberSessionChange
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
        guard let token = token, !token.isEmpty else { return }

        UserDefaults.standard.set(token, forKey: Constants.publicTokenDefaultsKey)

        let stytchClientConfiguration = StytchClientConfiguration(publicToken: token, defaultSessionDuration: 5)
        StytchB2BClient.configure(configuration: stytchClientConfiguration)

        navigationController?.pushViewController(AuthHomeViewController(), animated: true)
    }
}
