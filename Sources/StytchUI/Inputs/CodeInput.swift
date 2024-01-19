import UIKit

final class CodeInput: TextInputView<CodeField> {
    var text: String? { textInput.text }

    var onReturn: (Bool) -> Void = { _ in }

    // swiftlint:disable:next overridden_super_call
    override func setUp() {
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textInput, queue: .main) { [weak self] _ in
            guard let self else { return }
            self.onTextChanged(self.isValid)
        }
        textInput.textContentType = .oneTimeCode
        textInput.delegate = self
        textInput.accessibilityLabel = "otpEntry"
    }
}

final class CodeField: BorderedTextField, TextInputType {
    var isValid: Bool {
        guard let text else { return false }
        return text.allSatisfy(\.isNumber) && text.count == 6
    }

    var fields: [UIView] { [self] }
}

extension CodeInput: UITextFieldDelegate {
    func textField(_: UITextField, shouldChangeCharactersIn _: NSRange, replacementString string: String) -> Bool {
        string.allSatisfy(\.isNumber)
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        onReturn(isValid)
        return true
    }
}
