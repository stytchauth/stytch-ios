import StytchCore
import UIKit

final class AuthenticationViewController: UIViewController {
    var onAuthenticate: ((AuthenticateResponseType) -> Void)?

    private let signInWithGoogleButton: UIButton

    override func viewDidLoad() {
        super.viewDidLoad()

        signInWithGoogleButton.addTarget(self, action: #selector(didTapSignInWithGoogleButton(sender:)), for: [.touchUpInside])
        ...
    }

    private func handleAuthentication(response: AuthenticateResponseType) {
        ...
        onAuthenticate(response)
    }

    @objc private func didTapSignInWithGoogleButton(sender: UIButton) {
    }
}
