import Combine
import StytchCore
import UIKit

final class RootViewController: UIViewController {
    let stackView = UIStackView.stytchB2BStackView()
    var authChangeCancellable: AnyCancellable?

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

        publicTokenTextField.text = UserDefaults.standard.string(forKey: Constants.publicTokenDefaultsKey)

        authChangeCancellable = StytchB2BClient.sessions.onAuthChange
            .map { _ in StytchB2BClient.member.getSync() }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] member in
                self?.memberIdLabel.isHidden = member == nil
                self?.memberIdLabel.text = member.map { "Welcome, \($0.id.rawValue)!" } ?? "Logged out"
            })
    }

    func submit(token: String?) {
        guard let token = token, !token.isEmpty else { return }

        UserDefaults.standard.set(token, forKey: Constants.publicTokenDefaultsKey)
        StytchB2BClient.configure(publicToken: token)

        navigationController?.pushViewController(AuthHomeViewController(), animated: true)
    }
}
