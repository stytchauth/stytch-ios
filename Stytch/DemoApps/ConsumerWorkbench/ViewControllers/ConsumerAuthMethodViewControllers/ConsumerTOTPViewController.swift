import StytchCore
import SwiftOTP
import UIKit

final class ConsumerTOTPViewController: UIViewController {
    private let totpSecretDefaultsKey = "totpSecret"

    let stackView = UIStackView.stytchStackView()

    // Inputs
    lazy var totpCodeTextField: UITextField = .init(
        title: "TOTP Code",
        primaryAction: UIAction { [weak self] _ in self?.view.endEditing(true) },
        keyboardType: .numberPad
    )

    lazy var recoveryCodeTextField: UITextField = .init(
        title: "Recovery Code",
        primaryAction: UIAction { [weak self] _ in self?.view.endEditing(true) },
        keyboardType: .default
    )

    // Buttons
    lazy var createButton: UIButton = .init(
        title: "Create TOTP",
        primaryAction: .init { [weak self] _ in self?.submitCreate() }
    )

    lazy var authenticateButton: UIButton = .init(
        title: "Authenticate",
        primaryAction: .init { [weak self] _ in self?.submitAuthenticate() }
    )

    lazy var recoveryCodesButton: UIButton = .init(
        title: "Get Recovery Codes",
        primaryAction: .init { [weak self] _ in self?.submitRecoveryCodes() }
    )

    lazy var recoverButton: UIButton = .init(
        title: "Recover With Code",
        primaryAction: .init { [weak self] _ in self?.submitRecover() }
    )

    lazy var generateLocalCodeButton: UIButton = .init(
        title: "Generate Local Code",
        primaryAction: .init { [weak self] _ in self?.generateLocalTOTP() }
    )

    // Output
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "TOTP status unknown"
        return label
    }()

    private let secretLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Secret will appear after create"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Consumer TOTP"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(createButton)
        stackView.addArrangedSubview(secretLabel)
        stackView.addArrangedSubview(UIView.spacer(height: 16))
        stackView.addArrangedSubview(generateLocalCodeButton)
        stackView.addArrangedSubview(UIView.spacer(height: 24))

        stackView.addArrangedSubview(totpCodeTextField)
        stackView.addArrangedSubview(authenticateButton)
        stackView.addArrangedSubview(UIView.spacer(height: 16))

        stackView.addArrangedSubview(recoveryCodesButton)
        stackView.addArrangedSubview(UIView.spacer(height: 12))
        stackView.addArrangedSubview(recoveryCodeTextField)
        stackView.addArrangedSubview(recoverButton)
        stackView.addArrangedSubview(UIView.spacer(height: 16))

        stackView.addArrangedSubview(statusLabel)

        totpCodeTextField.delegate = self
        recoveryCodeTextField.delegate = self

        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditingTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        updateSecretLabelFromDefaults()
    }

    @objc private func endEditingTap() {
        view.endEditing(true)
    }

    private func updateSecretLabelFromDefaults() {
        if let savedSecret = UserDefaults.standard.string(forKey: totpSecretDefaultsKey),
           savedSecret.isEmpty == false
        {
            secretLabel.text = "Secret saved"
        } else {
            secretLabel.text = "Secret will appear after create"
        }
    }

    // Actions

    func submitCreate() {
        Task {
            do {
                let response = try await StytchClient.totps.create(parameters: .init())
                presentAlertAndLogMessage(description: "Create success", object: response)
                statusLabel.text = "TOTP created"

                // Save secret to UserDefaults
                UserDefaults.standard.set(response.secret, forKey: totpSecretDefaultsKey)
                secretLabel.text = "Secret saved"
            } catch {
                presentAlertAndLogMessage(description: "Create error", object: error)
                statusLabel.text = "Create failed"
            }
        }
    }

    func submitAuthenticate() {
        guard let code = totpCodeTextField.text, code.isEmpty == false else { return }
        Task {
            do {
                let response = try await StytchClient.totps.authenticate(
                    parameters: .init(totpCode: code, sessionDurationMinutes: StytchClient.defaultSessionDuration)
                )
                presentAlertAndLogMessage(description: "Authenticate success", object: response)
                statusLabel.text = "Authenticate success"
            } catch {
                presentAlertAndLogMessage(description: "Authenticate error", object: error)
                statusLabel.text = "Authenticate failed"
            }
        }
    }

    func submitRecoveryCodes() {
        Task {
            do {
                let response = try await StytchClient.totps.recoveryCodes()
                presentAlertAndLogMessage(description: "Recovery codes success", object: response)
                statusLabel.text = "Recovery codes retrieved"
            } catch {
                presentAlertAndLogMessage(description: "Recovery codes error", object: error)
                statusLabel.text = "Recovery codes failed"
            }
        }
    }

    func submitRecover() {
        guard let code = recoveryCodeTextField.text, code.isEmpty == false else { return }
        Task {
            do {
                let response = try await StytchClient.totps.recover(
                    parameters: .init(recoveryCode: code, sessionDurationMinutes: StytchClient.defaultSessionDuration)
                )
                presentAlertAndLogMessage(description: "Recover success", object: response)
                statusLabel.text = "Recover success"
            } catch {
                presentAlertAndLogMessage(description: "Recover error", object: error)
                statusLabel.text = "Recover failed"
            }
        }
    }

    func generateLocalTOTP() {
        guard
            let secret = UserDefaults.standard.string(forKey: totpSecretDefaultsKey),
            let dataSecret = base32DecodeToData(secret),
            let totp = TOTP(secret: dataSecret),
            let code = totp.generate(time: Date())
        else {
            presentAlertWithTitle(alertTitle: "Failed to generate the TOTP code")
            return
        }

        totpCodeTextField.text = code
    }
}

extension ConsumerTOTPViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
