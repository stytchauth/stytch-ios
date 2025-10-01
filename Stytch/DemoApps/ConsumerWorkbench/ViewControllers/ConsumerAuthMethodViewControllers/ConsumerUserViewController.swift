import Combine
import StytchCore
import SwiftyJSON
import UIKit

final class ConsumerUserViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()

    private var cancellables = Set<AnyCancellable>()

    // Inputs
    lazy var emailTextField: UITextField = .init(
        title: "Email",
        primaryAction: UIAction { [weak self] _ in self?.view.endEditing(true) },
        keyboardType: .emailAddress
    )

    lazy var givenNameTextField: UITextField = .init(
        title: "Given Name",
        primaryAction: UIAction { [weak self] _ in self?.view.endEditing(true) },
        keyboardType: .default
    )

    lazy var familyNameTextField: UITextField = .init(
        title: "Family Name",
        primaryAction: UIAction { [weak self] _ in self?.view.endEditing(true) },
        keyboardType: .default
    )

    lazy var untrustedMetadataTextField: UITextField = .init(
        title: "Untrusted Metadata JSON",
        primaryAction: UIAction { [weak self] _ in self?.view.endEditing(true) },
        keyboardType: .default
    )

    // Buttons
    lazy var getUserButton: UIButton = .init(
        title: "Get User",
        primaryAction: .init { [weak self] _ in self?.submitGetUser() }
    )

    lazy var updateUserButton: UIButton = .init(
        title: "Update User",
        primaryAction: .init { [weak self] _ in self?.submitUpdateUser() }
    )

    lazy var searchUserButton: UIButton = .init(
        title: "Search User By Email",
        primaryAction: .init { [weak self] _ in self?.submitSearchUser() }
    )

    // Output
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "User status unknown"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Consumer User"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        // Layout
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(getUserButton)
        stackView.addArrangedSubview(searchUserButton)

        stackView.addArrangedSubview(UIView.spacer(height: 24))

        stackView.addArrangedSubview(givenNameTextField)
        stackView.addArrangedSubview(familyNameTextField)
        stackView.addArrangedSubview(untrustedMetadataTextField)
        stackView.addArrangedSubview(updateUserButton)

        stackView.addArrangedSubview(UIView.spacer(height: 24))

        stackView.addArrangedSubview(statusLabel)

        // Defaults
        emailTextField.text = UserDefaults.standard.string(forKey: emailDefaultsKey)

        // Observe cached user changes
        StytchClient.user.onUserChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] info in
                switch info {
                case let .available(user, date):
                    self?.statusLabel.text = "User available, updated at \(date)"
                    // Optionally reflect name in fields
                    self?.givenNameTextField.text = user.name.firstName
                    self?.familyNameTextField.text = user.name.lastName
                case .unavailable:
                    self?.statusLabel.text = "User unavailable"
                }
            }
            .store(in: &cancellables)
    }

    // MARK: Actions

    func submitGetUser() {
        Task {
            do {
                let response = try await StytchClient.user.get()
                presentAlertAndLogMessage(description: "Get user success", object: response)
            } catch {
                presentAlertAndLogMessage(description: "Get user error", object: error)
            }
        }
    }

    func submitSearchUser() {
        guard let email = emailTextField.text, !email.isEmpty else { return }
        UserDefaults.standard.set(email, forKey: emailDefaultsKey)

        Task {
            do {
                let response = try await StytchClient.user.searchUser(email: email)
                presentAlertAndLogMessage(description: "Search user success", object: response)
            } catch {
                presentAlertAndLogMessage(description: "Search user error", object: error)
            }
        }
    }

    func submitUpdateUser() {
        let givenNameInput = givenNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let familyNameInput = familyNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        let userName: User.Name? = {
            let validatedFirstName = givenNameInput?.isEmpty == false ? givenNameInput : nil
            let validatedLastName = familyNameInput?.isEmpty == false ? familyNameInput : nil
            if validatedFirstName != nil || validatedLastName != nil {
                return .init(firstName: validatedFirstName, lastName: validatedLastName, middleName: nil)
            }
            return nil
        }()

        let untrustedMetadata: JSON? = {
            guard let untrustedMetadataText = untrustedMetadataTextField.text,
                  untrustedMetadataText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            else { return nil }

            if let jsonData = untrustedMetadataText.data(using: .utf8),
               let jsonObject = try? JSONSerialization.jsonObject(with: jsonData)
            {
                return JSON(jsonObject)
            }
            presentAlertAndLogMessage(description: "Metadata parse error", object: "Provide valid JSON")
            return nil
        }()

        Task {
            do {
                let response = try await StytchClient.user.update(
                    parameters: .init(name: userName, untrustedMetadata: untrustedMetadata)
                )
                presentAlertAndLogMessage(description: "Update user success", object: response)
            } catch {
                presentAlertAndLogMessage(description: "Update user error", object: error)
            }
        }
    }
}

extension ConsumerUserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
