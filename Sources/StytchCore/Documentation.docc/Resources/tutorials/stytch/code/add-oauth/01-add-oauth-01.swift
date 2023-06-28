import StytchCore
import UIKit

final class AuthenticationViewController: UIViewController {
    var onAuthenticate: ((AuthenticateResponseType) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        ...
    }

    private func handleAuthentication(response: AuthenticateResponseType) {
        ...
        onAuthenticate(response)
    }
}
