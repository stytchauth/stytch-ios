import UIKit

final class SecureTextInput: TextInputView<SecureTextField> {
    var text: String? { textInput.text }

    override func setUp() {
        textInput.addTarget(self, action: #selector(textDidChange(sender:)), for: .editingChanged)
    }

    @objc private func textDidChange(sender: UITextField) {
        onTextChanged(isValid)
    }
}

final class SecureTextField: BorderedTextField, TextInputType {
    var isValid: Bool { text?.isEmpty == false }

    var fields: [UIView] { [self] }

    override init(frame: CGRect) {
        super.init(frame: frame)
        autocorrectionType = .no
        autocapitalizationType = .none
        isSecureTextEntry = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
