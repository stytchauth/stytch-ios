import StytchCore
import UIKit

final class AuthenticationViewController: UIViewController {
    var onAuthenticate: ((AuthenticateResponseType) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        ...
    }

    private func canPerformBiometricCheck() -> Bool {
        var error: NSError?
        guard LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error), error == nil else {
            return false
        }
        return true
    }
}
