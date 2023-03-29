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
        codeTextField.delegate = self

        submitButton.addTarget(self, action: #selector(didSubmitCode), for: [.touchUpInside])
    }

    @objc private func didSubmitCode() {
    }
}

extension OTPVerificationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == codeTextField {
            didSubmitCode()
        }
        return true
    }
}
