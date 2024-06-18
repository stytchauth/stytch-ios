import StytchCore
import SwiftOTP
import UIKit

final class OTPViewController: UIViewController {
    let stackView = UIStackView.stytchB2BStackView()

    lazy var sendButton: UIButton = .init(title: "Send OTP", primaryAction: .init { [weak self] _ in
        self?.send()
    })

    lazy var authenticateButton: UIButton = .init(title: "Authenticate", primaryAction: .init { [weak self] _ in
        self?.authenticate()
    })

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "TOTP"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(sendButton)
        stackView.addArrangedSubview(authenticateButton)
    }

    func send() {
        guard let organizationId = organizationId, let memberId = memberId else {
            presentAlertWithTitle(alertTitle: "No member or organization ID, you need to authenticate first.")
            return
        }

        Task {
            do {
                guard let phoneNumber = try await presentTextFieldAlertWithTitle(alertTitle: "Enter Your Phone Number In The Format +1xxxxxxxxxx") else {
                    throw TextFieldAlertError.emptyString
                }

                let parameters = StytchB2BClient.OTP.SendParameters(
                    organizationId: organizationId,
                    memberId: memberId,
                    mfaPhoneNumber: phoneNumber,
                    locale: nil
                )
                let response = try await StytchB2BClient.otp.send(parameters: parameters)
                presentAlertAndLogMessage(description: "send otp success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "send otp error", object: error)
            }
        }
    }

    func authenticate() {
        guard let organizationId = organizationId, let memberId = memberId else {
            presentAlertWithTitle(alertTitle: "No member or organization ID, you need to authenticate first.")
            return
        }

        Task {
            do {
                guard let code = try await presentTextFieldAlertWithTitle(alertTitle: "Enter The OTP Code") else {
                    throw TextFieldAlertError.emptyString
                }

                let parameters = StytchB2BClient.OTP.AuthenticateParameters(
                    sessionDurationMinutes: .defaultSessionDuration,
                    organizationId: organizationId,
                    memberId: memberId,
                    code: code,
                    setMfaEnrollment: nil
                )
                let response = try await StytchB2BClient.otp.authenticate(parameters: parameters)
                presentAlertAndLogMessage(description: "authenticate otp success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "authenticate otp error", object: error)
            }
        }
    }
}
