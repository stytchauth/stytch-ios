import Combine
import StytchCore
import UIKit

final class StytchConsumerSessionsViewController: UIViewController {
    var cancellables: Set<AnyCancellable> = []

    let stackView = UIStackView.stytchStackView()

    lazy var smsOtpButton: UIButton = .init(title: "SMS OTP", primaryAction: .init { [weak self] _ in
        self?.sendAndAuthenticateSmsOtp()
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

        title = "Consumer"

        let stytchClientConfiguration = StytchClientConfiguration(publicToken: "your-public-token", defaultSessionDuration: 5)
        StytchClient.configure(configuration: stytchClientConfiguration)

        view.backgroundColor = .systemBackground

        sessionLabel.numberOfLines = 0

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(smsOtpButton)
        stackView.addArrangedSubview(authenticateButton)
        stackView.addArrangedSubview(revokeButton)
        stackView.addArrangedSubview(spamButton)
        stackView.addArrangedSubview(sessionLabel)

        StytchClient.sessions.onSessionChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionInfo in
                switch sessionInfo {
                case let .available(session, lastValidatedAtDate):
                    self?.sessionLabel.text =
                        """
                        Session Available!
                        Expires: \(dateFormatter.string(from: session.expiresAt))
                        Validated: \(dateFormatter.string(from: lastValidatedAtDate))
                        """
                case .unavailable:
                    self?.sessionLabel.text = "Session Unavailable"
                }
            }.store(in: &cancellables)
    }

    func sendAndAuthenticateSmsOtp() {
        Task {
            do {
                guard let phoneNumber = try await presentTextFieldAlertWithTitle(alertTitle: "Enter Your Phone Number In The Format xxxxxxxxxx", keyboardType: .numberPad) else {
                    throw TextFieldAlertError.emptyString
                }
                let loginOrCreateResponse = try await StytchClient.otps.loginOrCreate(parameters: .init(deliveryMethod: .sms(phoneNumber: "+1\(phoneNumber)", enableAutofill: false)))

                guard let code = try await presentTextFieldAlertWithTitle(alertTitle: "Enter The OTP Code", keyboardType: .numberPad) else {
                    throw TextFieldAlertError.emptyString
                }
                _ = try await StytchClient.otps.authenticate(parameters: .init(code: code, methodId: loginOrCreateResponse.methodId))
                presentAlertWithTitle(alertTitle: "Authetication Success!")
            } catch {
                print(error.errorInfo)
            }
        }
    }

    func authenticate() {
        Task {
            do {
                _ = try await StytchClient.sessions.authenticate(parameters: .init())
                print("Sessions Authetication Success!")
            } catch {
                print(error.errorInfo)
            }
        }
    }

    func revoke() {
        Task {
            do {
                _ = try await StytchClient.sessions.revoke()
                print("Sessions Revoke Success!")
            } catch {
                print(error.errorInfo)
            }
        }
    }

    func spam() {
        Task {
            do {
                _ = try await StytchClient.sessions.authenticate(parameters: .init())
                _ = try await StytchClient.sessions.revoke()
                // Put test code around spamming authenticate and revoke here
            } catch {
                print(error.errorInfo)
            }
        }
    }
}
