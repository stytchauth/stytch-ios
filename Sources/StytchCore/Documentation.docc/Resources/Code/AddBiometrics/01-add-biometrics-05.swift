import StytchCore
import UIKit

final class AuthenticationViewController: UIViewController {
    var onAuthenticate: ((AuthenticateResponseType) -> Void)?

    private let biometricsButton: UIButton

    override func viewDidLoad() {
        super.viewDidLoad()

        biometricsButton.addTarget(self, action: #selector(didTapBiometricsButton(sender:)), for: [.touchUpInside])
        ...
    }

    private func handleAuthentication(response: AuthenticateResponseType) {
        if canPerformBiometricCheck(), !StytchClient.biometrics.registrationAvailable {
            promptForBiometricsRegistration(user: response.user)
        }
        onAuthenticate(response)
    }

    private func promptForBiometricRegistration(user: User) {
        let message = "Register for Biometrics!"
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(.init(title: "OK", style: .default) { [weak self] _ in
        })
        present(alertController, animated: true)
    }

    private func updateBiometricsButtonHidden() {
        guard canPerformBiometricCheck(), StytchClient.biometrics.registrationAvailable else {
            biometricsButton.isHidden = true
            return
        }

        biometricsButton.isHidden = false
    }

    @objc private func didTapBiometricsButton(sender: UIButton) {
        Task {
            do {
                let authResponse = try await StytchClient.biometrics.authenticate(parameters: .init())
                handleAuthentication(response: authResponse)
            } catch {}
        }
    }

    private func canPerformBiometricCheck() -> Bool {
        var error: NSError?
        guard LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error), error == nil else {
            return false
        }
        return true
    }
}
