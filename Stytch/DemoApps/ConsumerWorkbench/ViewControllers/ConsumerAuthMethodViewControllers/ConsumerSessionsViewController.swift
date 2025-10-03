import Combine
import StytchCore
import UIKit

final class ConsumerSessionsViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()
    private var cancellables = Set<AnyCancellable>()

    // Inputs
    lazy var durationMinutesTextField: UITextField = .init(
        title: "Session Duration Minutes (optional)",
        primaryAction: UIAction { [weak self] _ in self?.view.endEditing(true) },
        keyboardType: .numberPad
    )

    // Buttons
    lazy var authenticateButton: UIButton = .init(
        title: "Authenticate Session",
        primaryAction: .init { [weak self] _ in self?.submitAuthenticate() }
    )

    lazy var revokeButton: UIButton = .init(
        title: "Revoke Session",
        primaryAction: .init { [weak self] _ in self?.submitRevoke() }
    )

    // Output
    private let sessionStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "Session status unknown"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Consumer Sessions"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        // Layout
        stackView.addArrangedSubview(durationMinutesTextField)
        stackView.addArrangedSubview(authenticateButton)
        stackView.addArrangedSubview(revokeButton)
        stackView.addArrangedSubview(UIView.spacer(height: 16))
        stackView.addArrangedSubview(sessionStatusLabel)

        // Dismiss keyboard on tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditingTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        // Observe session changes
        StytchClient.sessions.onSessionChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] info in
                switch info {
                case let .available(_, date):
                    self?.sessionStatusLabel.text = "Session available, validated at \(date)"
                case .unavailable:
                    self?.sessionStatusLabel.text = "No active session"
                }
            }
            .store(in: &cancellables)
    }

    @objc private func endEditingTap() {
        view.endEditing(true)
    }

    private func parsedDuration() -> Minutes? {
        guard let text = durationMinutesTextField.text,
              text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
              let value = Int(text) else { return nil }
        return Minutes(rawValue: UInt(value))
    }

    // Actions

    func submitAuthenticate() {
        Task {
            do {
                let response = try await StytchClient.sessions.authenticate(
                    parameters: .init(sessionDurationMinutes: parsedDuration())
                )
                presentAlertAndLogMessage(description: "Authenticate success", object: response)
                sessionStatusLabel.text = "Authenticate success"
            } catch {
                presentAlertAndLogMessage(description: "Authenticate error", object: error)
                sessionStatusLabel.text = "Authenticate failed"
            }
        }
    }

    func submitRevoke() {
        Task {
            do {
                let response = try await StytchClient.sessions.revoke()
                presentAlertAndLogMessage(description: "Revoke success", object: response)
                sessionStatusLabel.text = "Session revoked"
            } catch {
                presentAlertAndLogMessage(description: "Revoke error", object: error)
                sessionStatusLabel.text = "Revoke failed"
            }
        }
    }
}

extension ConsumerSessionsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
