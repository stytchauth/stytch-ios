import StytchCore
import SwiftOTP
import UIKit

final class TOTPViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()

    lazy var createButton: UIButton = .init(title: "Create TOTP", primaryAction: .init { [weak self] _ in
        self?.create()
    })

    lazy var authenticateButton: UIButton = .init(title: "Authenticate", primaryAction: .init { [weak self] _ in
        self?.authenticate()
    })

    private var secret: String?

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

        stackView.addArrangedSubview(createButton)
        stackView.addArrangedSubview(authenticateButton)
    }

    func create() {
        guard let organizationId = organizationId, let memberId = memberId else {
            presentAlertWithTitle(alertTitle: "No member or organization ID, you need to authenticate first.")
            return
        }

        Task {
            do {
                let parameters = StytchB2BClient.TOTP.CreateParameters(organizationId: organizationId, memberId: memberId, expirationMinutes: 30)
                let response = try await StytchB2BClient.totp.create(parameters: parameters)
                secret = response.wrapped.secret
                presentAlertAndLogMessage(description: "create totp success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "create totp error", object: error)
            }
        }
    }

    func authenticate() {
        guard
            let organizationId = organizationId,
            let memberId = memberId
        else {
            presentAlertWithTitle(alertTitle: "No member or organization ID, you need to authenticate first.")
            return
        }

        guard
            let secret = secret,
            let dataSecret = base32DecodeToData(secret),
            let totp = TOTP(secret: dataSecret),
            let code = totp.generate(time: Date())
        else {
            presentAlertWithTitle(alertTitle: "Failed to generate the the totp code")
            return
        }

        Task {
            do {
                let parameters = StytchB2BClient.TOTP.AuthenticateParameters(
                    organizationId: organizationId,
                    memberId: memberId,
                    code: code,
                    setMfaEnrollment: nil,
                    setDefaultMfa: false
                )
                let response = try await StytchB2BClient.totp.authenticate(parameters: parameters)
                presentAlertAndLogMessage(description: "authenticate totp success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "authenticate totp error", object: error)
            }
        }
    }
}
