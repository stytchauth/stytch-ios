import StytchCore
import UIKit

final class AuthenticationViewController: UIViewController {
    var onAuthenticate: ((AuthenticateResponseType) -> Void)?

    private let signInWithGoogleButton: UIButton

    override func viewDidLoad() {
        super.viewDidLoad()

        ...
    }

    private func handleAuthentication(response: AuthenticateResponseType) {
        ...
        onAuthenticate(response)
    }
}
