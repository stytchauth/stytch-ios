import StytchCore
import UIKit

final class RecoveryCodesViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()

    lazy var getButton: UIButton = .init(title: "Get", primaryAction: .init { [weak self] _ in
        self?.get()
    })

    lazy var rotateButton: UIButton = .init(title: "Rotate", primaryAction: .init { [weak self] _ in
        self?.rotate()
    })

    lazy var recoverButton: UIButton = .init(title: "Recover", primaryAction: .init { [weak self] _ in
        self?.recover()
    })

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Recovery Codes"

        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(getButton)
        stackView.addArrangedSubview(rotateButton)
        stackView.addArrangedSubview(recoverButton)
    }

    func get() {
        Task {
            do {
                let response = try await StytchB2BClient.recoveryCodes.get()
                presentAlertAndLogMessage(description: "recovery codes get success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "recovery codes get error", object: error)
            }
        }
    }

    func rotate() {
        Task {
            do {
                let response = try await StytchB2BClient.recoveryCodes.rotate()
                presentAlertAndLogMessage(description: "recovery codes rotate success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "recovery codes rotate error", object: error)
            }
        }
    }

    func recover() {
        guard let organizationId = organizationId, let memberId = memberId else {
            presentAlertWithTitle(alertTitle: "No member or organization ID, you need to authenticate first.")
            return
        }

        Task {
            guard let recoveryCode = try await presentTextFieldAlertWithTitle(alertTitle: "Enter The Recovery Code") else {
                throw TextFieldAlertError.emptyString
            }

            do {
                let parameters = StytchB2BClient.RecoveryCodes.RecoveryCodesRecoverParameters(
                    organizationId: organizationId,
                    memberId: memberId,
                    recoveryCode: recoveryCode
                )
                let response = try await StytchB2BClient.recoveryCodes.recover(parameters: parameters)
                presentAlertAndLogMessage(description: "recovery codes recover success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "recovery codes recover error", object: error)
            }
        }
    }
}
