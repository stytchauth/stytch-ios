import StytchCore
import UIKit

final class SessionsViewController: UIViewController {
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.layoutMargins = Constants.insets
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        view.spacing = 8
        return view
    }()

    private lazy var authenticateButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Authenticate"
        return .init(configuration: configuration, primaryAction: authenticateAction)
    }()

    private lazy var revokeButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Revoke"
        return .init(configuration: configuration, primaryAction: revokeAction)
    }()

    private lazy var authenticateAction: UIAction = .init { _ in
        Task {
            do {
                let resp = try await StytchB2BClient.sessions.authenticate(parameters: .init())
                print(resp)
            } catch {
                print("authenticateAction error: \(error.errorInfo)")
            }
        }
    }

    private lazy var revokeAction: UIAction = .init { _ in
        Task {
            do {
                let resp = try await StytchB2BClient.sessions.revoke()
                print(resp)
            } catch {
                print("revokeAction error: \(error.errorInfo)")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Sessions"

        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(authenticateButton)
        stackView.addArrangedSubview(revokeButton)
    }
}
