import StytchCore
import UIKit

final class OTPVerificationViewController: UIViewController {
    private var methodId: String

    private var onAuthenticate: (AuthenticateResponseType) -> Void

    private var session: Session

    private let submitButton: UIButton

    private let codeTextField: UITextfield

    override func viewDidLoad() {
        super.viewDidLoad()

        codeTextField.textContentType = .oneTimeCode
    }

    @objc private func didSubmitCode() {
    }
}
