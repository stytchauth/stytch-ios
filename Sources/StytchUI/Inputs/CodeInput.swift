import UIKit

final class CodeInput: TextInputView<CodeField> {
    var text: String? { textInput.text }

    var onReturn: (Bool) -> Void = { _ in }

    override func setUp() {
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textInput, queue: .main) { [weak self] notification in
            guard let self else { return }
            self.onTextChanged(self.isValid)
        }
        textInput.textContentType = .oneTimeCode
        textInput.delegate = self
    }
}

final class CodeField: BorderedTextField, TextInputType {
    var isValid: Bool {
        guard let text else { return false }
        return text.allSatisfy { $0.isNumber } && text.count == 6
    }

    var fields: [UIView] { [self] }
}

extension CodeInput: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        string.allSatisfy { $0.isNumber }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturn(isValid)
        return true
    }
}
