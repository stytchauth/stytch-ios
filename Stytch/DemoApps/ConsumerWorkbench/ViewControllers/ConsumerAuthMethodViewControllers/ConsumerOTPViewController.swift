import StytchCore
import UIKit

final class ConsumerOTPViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()

    // Method selector
    private lazy var methodSegment: UISegmentedControl = {
        let control = UISegmentedControl(items: ["SMS", "WhatsApp", "Email"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(methodChanged), for: .valueChanged)
        return control
    }()

    // Inputs
    lazy var phoneTextField: UITextField = .init(
        title: "Phone Number (+1XXXXXXXXXX)",
        primaryAction: UIAction { [weak self] _ in self?.view.endEditing(true) },
        keyboardType: .phonePad
    )

    lazy var emailTextField: UITextField = .init(
        title: "Email",
        primaryAction: UIAction { [weak self] _ in self?.view.endEditing(true) },
        keyboardType: .emailAddress
    )

    lazy var codeTextField: UITextField = .init(
        title: "OTP Code",
        primaryAction: UIAction { [weak self] _ in self?.view.endEditing(true) },
        keyboardType: .numberPad
    )

    lazy var methodIdTextField: UITextField = .init(
        title: "Method Id",
        primaryAction: UIAction { [weak self] _ in self?.view.endEditing(true) },
        keyboardType: .default
    )

    // Buttons
    lazy var loginOrCreateButton: UIButton = .init(
        title: "Login Or Create",
        primaryAction: .init { [weak self] _ in self?.submitLoginOrCreate() }
    )

    lazy var sendButton: UIButton = .init(
        title: "Send",
        primaryAction: .init { [weak self] _ in self?.submitSend() }
    )

    lazy var authenticateButton: UIButton = .init(
        title: "Authenticate",
        primaryAction: .init { [weak self] _ in self?.submitAuthenticate() }
    )

    // Output
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "OTP status unknown"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Consumer OTP"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(methodSegment)
        stackView.addArrangedSubview(phoneTextField)
        stackView.addArrangedSubview(emailTextField)

        stackView.addArrangedSubview(loginOrCreateButton)
        stackView.addArrangedSubview(sendButton)
        stackView.addArrangedSubview(UIView.spacer(height: 16))

        stackView.addArrangedSubview(methodIdTextField)
        stackView.addArrangedSubview(codeTextField)
        stackView.addArrangedSubview(authenticateButton)
        stackView.addArrangedSubview(UIView.spacer(height: 16))

        stackView.addArrangedSubview(statusLabel)

        // Defaults
        emailTextField.text = UserDefaults.standard.string(forKey: emailDefaultsKey)

        // Delegates
        [phoneTextField, emailTextField, codeTextField, methodIdTextField].forEach { $0.delegate = self }

        // Dismiss keyboard on tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditingTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        // Initial visibility
        updateMethodInputs()
    }

    @objc private func endEditingTap() {
        view.endEditing(true)
    }

    @objc private func methodChanged() {
        updateMethodInputs()
    }

    private func updateMethodInputs() {
        let isSMS = methodSegment.selectedSegmentIndex == 0
        let isWhatsApp = methodSegment.selectedSegmentIndex == 1
        let isEmail = methodSegment.selectedSegmentIndex == 2

        phoneTextField.isHidden = !(isSMS || isWhatsApp)
        emailTextField.isHidden = !isEmail
    }

    private func currentDeliveryMethod() -> StytchClient.OTP.DeliveryMethod? {
        switch methodSegment.selectedSegmentIndex {
        case 0:
            guard let phone = phoneTextField.text, phone.isEmpty == false else { return nil }
            return .sms(phoneNumber: phone)
        case 1:
            guard let phone = phoneTextField.text, phone.isEmpty == false else { return nil }
            return .whatsapp(phoneNumber: phone)
        case 2:
            guard let email = emailTextField.text, email.isEmpty == false else { return nil }
            return .email(email: email)
        default:
            return nil
        }
    }

    // Actions

    func submitLoginOrCreate() {
        guard let delivery = currentDeliveryMethod() else {
            presentAlertWithTitle(alertTitle: "Provide required fields for the selected method")
            return
        }

        if case let .email(email, _, _) = delivery {
            UserDefaults.standard.set(email, forKey: emailDefaultsKey)
        }

        Task {
            do {
                let response = try await StytchClient.otps.loginOrCreate(
                    parameters: .init(deliveryMethod: delivery, expirationMinutes: nil, locale: .en)
                )
                methodIdTextField.text = response.methodId
                presentAlertAndLogMessage(description: "login or create success, method id saved", object: response)
                statusLabel.text = "Login or create success"
            } catch {
                presentAlertAndLogMessage(description: "login or create error", object: error)
                statusLabel.text = "Login or create failed"
            }
        }
    }

    func submitSend() {
        guard let delivery = currentDeliveryMethod() else {
            presentAlertWithTitle(alertTitle: "Provide required fields for the selected method")
            return
        }

        if case let .email(email, _, _) = delivery {
            UserDefaults.standard.set(email, forKey: emailDefaultsKey)
        }

        Task {
            do {
                let response = try await StytchClient.otps.send(
                    parameters: .init(deliveryMethod: delivery, expirationMinutes: nil, locale: .en)
                )
                methodIdTextField.text = response.methodId
                presentAlertAndLogMessage(description: "send success, method id saved", object: response)
                statusLabel.text = "Send success"
            } catch {
                presentAlertAndLogMessage(description: "send error", object: error)
                statusLabel.text = "Send failed"
            }
        }
    }

    func submitAuthenticate() {
        guard
            let methodId = methodIdTextField.text, methodId.isEmpty == false,
            let code = codeTextField.text, code.isEmpty == false
        else {
            presentAlertWithTitle(alertTitle: "Enter method id and code")
            return
        }

        Task {
            do {
                let response = try await StytchClient.otps.authenticate(
                    parameters: .init(code: code, methodId: methodId, sessionDurationMinutes: StytchClient.defaultSessionDuration)
                )
                presentAlertAndLogMessage(description: "authenticate success", object: response)
                statusLabel.text = "Authenticate success"
            } catch {
                presentAlertAndLogMessage(description: "authenticate error", object: error)
                statusLabel.text = "Authenticate failed"
            }
        }
    }
}

extension ConsumerOTPViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
