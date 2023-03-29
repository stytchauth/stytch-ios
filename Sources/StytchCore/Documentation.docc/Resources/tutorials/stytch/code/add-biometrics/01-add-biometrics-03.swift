import StytchCore
import UIKit

final class AuthenticationViewController: UIViewController {
    var onAuthenticate: ((AuthenticateResponseType) -> Void)?

    private let biometricsButton: UIButton

    override func viewDidLoad() {
        super.viewDidLoad()
        ...
    }

    private func updateBiometricsButtonHidden() {
        guard canPerformBiometricCheck(), StytchClient.biometrics.registrationAvailable else {
            biometricsButton.isHidden = true
            return
        }

        biometricsButton.isHidden = false
    }

    private func canPerformBiometricCheck() -> Bool {
        var error: NSError?
        guard LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error), error == nil else {
            return false
        }
        return true
    }
}
