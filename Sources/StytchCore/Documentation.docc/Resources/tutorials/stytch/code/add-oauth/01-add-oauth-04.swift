import StytchCore
import UIKit

final class AuthenticationViewController: UIViewController {
    var onAuthenticate: ((AuthenticateResponseType) -> Void)?

    private let signInWithAppleButton: UIButton

    override func viewDidLoad() {
        super.viewDidLoad()

        signInWithAppleButton.addTarget(self, action: #selector(didTapSignInWithAppleButton(sender:)), for: [.touchUpInside])
        ...
    }

    private func handleAuthentication(response: AuthenticateResponseType) {
        ...
        onAuthenticate(response)
    }

    @objc private func didTapSignInWithAppleButton(sender: UIButton) {
        Task {
            do {
                let authResponse = try await StytchClient.oauth.apple.start(parameters: .init())
                handleAuthentication(response: authResponse)
            } catch {}
        }
    }
}
