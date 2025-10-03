import StytchCore
import SwiftOTP
import UIKit

final class OTPViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()

    lazy var smsSendButton: UIButton = .init(title: "Send SMS OTP", primaryAction: .init { [weak self] _ in
        self?.smsSend()
    })

    lazy var smsAuthenticateButton: UIButton = .init(title: "SMS Authenticate", primaryAction: .init { [weak self] _ in
        self?.smsAuthenticate()
    })

    lazy var emailLoginOrSignupButton: UIButton = .init(title: "Login Or Signup Email OTP", primaryAction: .init { [weak self] _ in
        self?.emailLoginOrSignup()
    })

    lazy var emailAuthenticateButton: UIButton = .init(title: "Email Authenticate", primaryAction: .init { [weak self] _ in
        self?.emailAuthenticate()
    })

    lazy var emailDiscoverySendButton: UIButton = .init(title: "Email Discovery Send", primaryAction: .init { [weak self] _ in
        self?.emailDiscoverySend()
    })

    lazy var emailDiscoveryAuthenticateButton: UIButton = .init(title: "Email Discovery Authenticate", primaryAction: .init { [weak self] _ in
        self?.emailDiscoveryAuthenticate()
    })

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "OTP"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(smsSendButton)
        stackView.addArrangedSubview(smsAuthenticateButton)
        stackView.addArrangedSubview(emailLoginOrSignupButton)
        stackView.addArrangedSubview(emailAuthenticateButton)
        stackView.addArrangedSubview(emailDiscoverySendButton)
        stackView.addArrangedSubview(emailDiscoveryAuthenticateButton)
    }

    func smsSend() {
        guard let organizationId = organizationId, let memberId = memberId else {
            presentAlertWithTitle(alertTitle: "No member or organization ID, you need to authenticate first.")
            return
        }

        Task {
            do {
                guard let phoneNumber = try await presentTextFieldAlertWithTitle(alertTitle: "Enter Your Phone Number In The Format +1xxxxxxxxxx") else {
                    throw TextFieldAlertError.emptyString
                }

                let parameters = StytchB2BClient.OTP.SMS.SendParameters(
                    organizationId: organizationId,
                    memberId: memberId,
                    mfaPhoneNumber: phoneNumber,
                    locale: .en
                )
                let response = try await StytchB2BClient.otp.sms.send(parameters: parameters)
                presentAlertAndLogMessage(description: "send otp success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "send otp error", object: error)
            }
        }
    }

    func smsAuthenticate() {
        guard let organizationId = organizationId, let memberId = memberId else {
            presentAlertWithTitle(alertTitle: "No member or organization ID, you need to authenticate first.")
            return
        }

        Task {
            do {
                guard let code = try await presentTextFieldAlertWithTitle(alertTitle: "Enter The OTP Code") else {
                    throw TextFieldAlertError.emptyString
                }

                let parameters = StytchB2BClient.OTP.SMS.AuthenticateParameters(
                    organizationId: organizationId,
                    memberId: memberId,
                    code: code,
                    setMfaEnrollment: nil
                )
                let response = try await StytchB2BClient.otp.sms.authenticate(parameters: parameters)
                presentAlertAndLogMessage(description: "authenticate otp success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "authenticate otp error", object: error)
            }
        }
    }

    func emailLoginOrSignup() {
        guard let organizationId = organizationId else {
            presentAlertWithTitle(alertTitle: "No organization ID, you need to authenticate first.")
            return
        }

        Task {
            do {
                guard let emailAddress = try await presentTextFieldAlertWithTitle(alertTitle: "Enter Your Email Address") else {
                    throw TextFieldAlertError.emptyString
                }

                let parameters = StytchB2BClient.OTP.Email.LoginOrSignupParameters(
                    organizationId: organizationId,
                    emailAddress: emailAddress,
                    loginTemplateId: nil,
                    signupTemplateId: nil,
                    locale: .en
                )
                let response = try await StytchB2BClient.otp.email.loginOrSignup(parameters: parameters)
                presentAlertAndLogMessage(description: "send otp email success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "send otp email error", object: error)
            }
        }
    }

    func emailAuthenticate() {
        guard let organizationId = organizationId else {
            presentAlertWithTitle(alertTitle: "No organization ID, you need to authenticate first.")
            return
        }

        Task {
            do {
                guard let code = try await presentTextFieldAlertWithTitle(alertTitle: "Enter The OTP Code") else {
                    throw TextFieldAlertError.emptyString
                }
                guard let emailAddress = try await presentTextFieldAlertWithTitle(alertTitle: "Enter Your Email Address") else {
                    throw TextFieldAlertError.emptyString
                }

                let parameters = StytchB2BClient.OTP.Email.AuthenticateParameters(
                    code: code,
                    organizationId: organizationId,
                    emailAddress: emailAddress,
                    locale: .en
                )
                let response = try await StytchB2BClient.otp.email.authenticate(parameters: parameters)
                presentAlertAndLogMessage(description: "authenticate otp email success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "authenticate otp email error", object: error)
            }
        }
    }

    func emailDiscoverySend() {
        Task {
            do {
                guard let emailAddress = try await presentTextFieldAlertWithTitle(alertTitle: "Enter Your Email Address") else {
                    throw TextFieldAlertError.emptyString
                }

                let parameters = StytchB2BClient.OTP.Email.Discovery.SendParameters(
                    emailAddress: emailAddress,
                    loginTemplateId: nil,
                    locale: .en
                )
                let response = try await StytchB2BClient.otp.email.discovery.send(parameters: parameters)
                presentAlertAndLogMessage(description: "Discovery send success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "Discovery send error", object: error)
            }
        }
    }

    func emailDiscoveryAuthenticate() {
        Task {
            do {
                guard let code = try await presentTextFieldAlertWithTitle(alertTitle: "Enter The OTP Code") else {
                    throw TextFieldAlertError.emptyString
                }
                guard let emailAddress = try await presentTextFieldAlertWithTitle(alertTitle: "Enter Your Email Address") else {
                    throw TextFieldAlertError.emptyString
                }

                let parameters = StytchB2BClient.OTP.Email.Discovery.AuthenticateParameters(
                    code: code,
                    emailAddress: emailAddress
                )
                let response = try await StytchB2BClient.otp.email.discovery.authenticate(parameters: parameters)
                presentAlertAndLogMessage(description: "Discovery authenticate success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "Discovery authenticate error", object: error)
            }
        }
    }
}
