import UIKit

final class CodeInput: TextInputView<CodeField> {
    var text: String? { textInput.text }

    override func setUp() {
        textInput.textContentType = .oneTimeCode
        textInput.delegate = self
    }
}

final class CodeField: BorderedTextField, TextInputType {
    var isValid: Bool { text?.isEmpty == false }

    var fields: [UIView] { [self] }
}

extension CodeInput: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        string.allSatisfy { $0.isNumber }
    }
}
