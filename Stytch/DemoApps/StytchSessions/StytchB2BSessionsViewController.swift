import Combine
import StytchCore
import UIKit

final class StytchB2BSessionsViewController: UIViewController {
    var cancellables: Set<AnyCancellable> = []

    let stackView = UIStackView.stytchStackView()

    let organizationId = ""

    lazy var emailOtpButton: UIButton = .init(title: "Email OTP", primaryAction: .init { [weak self] _ in
        self?.sendAndAuthenticateEmailOtp()
    })

    lazy var authenticateButton: UIButton = .init(title: "Authenticate", primaryAction: .init { [weak self] _ in
        self?.authenticate()
    })

    lazy var revokeButton: UIButton = .init(title: "Revoke", primaryAction: .init { [weak self] _ in
        self?.revoke()
    })

    lazy var spamButton: UIButton = .init(title: "Spam", primaryAction: .init { [weak self] _ in
        self?.spam()
    })

    var sessionLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "B2B"

        let stytchClientConfiguration = StytchClientConfiguration(publicToken: "your-public-token", defaultSessionDuration: 5)
        StytchB2BClient.configure(configuration: stytchClientConfiguration)

        view.backgroundColor = .systemBackground

        sessionLabel.numberOfLines = 0

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(emailOtpButton)
        stackView.addArrangedSubview(authenticateButton)
        stackView.addArrangedSubview(revokeButton)
        stackView.addArrangedSubview(spamButton)
        stackView.addArrangedSubview(sessionLabel)

        StytchB2BClient.sessions.onMemberSessionChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] memberSessionInfo in
                switch memberSessionInfo {
                case let .available(memberSessionInfo, lastValidatedAtDate):
                    self?.sessionLabel.text =
                        """
                        Member Session Available!
                        Expires: \(dateFormatter.string(from: memberSessionInfo.expiresAt))
                        Validated: \(dateFormatter.string(from: lastValidatedAtDate))
                        """
                case .unavailable:
                    self?.sessionLabel.text = "Member Session Unavailable"
                }
            }.store(in: &cancellables)
    }

    func sendAndAuthenticateEmailOtp() {
        Task {
            do {
                guard let emailAddress = try await presentTextFieldAlertWithTitle(alertTitle: "Enter Your Email Address") else {
                    throw TextFieldAlertError.emptyString
                }

                let loginOrSignupParameters = StytchB2BClient.OTP.Email.LoginOrSignupParameters(
                    organizationId: organizationId,
                    emailAddress: emailAddress,
                )
                _ = try await StytchB2BClient.otp.email.loginOrSignup(parameters: loginOrSignupParameters)

                guard let code = try await presentTextFieldAlertWithTitle(alertTitle: "Enter The OTP Code") else {
                    throw TextFieldAlertError.emptyString
                }

                let authenticateParameters = StytchB2BClient.OTP.Email.AuthenticateParameters(
                    code: code,
                    organizationId: organizationId,
                    emailAddress: emailAddress
                )
                _ = try await StytchB2BClient.otp.email.authenticate(parameters: authenticateParameters)
                presentAlertWithTitle(alertTitle: "Authetication Success!")
            } catch {
                print(error.errorInfo)
            }
        }
    }

    func authenticate() {
        Task {
            do {
                _ = try await StytchB2BClient.sessions.authenticate(parameters: .init())
                print("Sessions Authetication Success!")
            } catch {
                print(error.errorInfo)
            }
        }
    }

    func revoke() {
        Task {
            do {
                _ = try await StytchB2BClient.sessions.revoke()
                print("Sessions Revoke Success!")
            } catch {
                print(error.errorInfo)
            }
        }
    }

    func spam() {
        Task {
            do {
                _ = try await StytchB2BClient.sessions.authenticate(parameters: .init())
                _ = try await StytchB2BClient.sessions.revoke()
                // Put test code around spamming authenticate and revoke here
            } catch {
                print(error.errorInfo)
            }
        }
    }
}
