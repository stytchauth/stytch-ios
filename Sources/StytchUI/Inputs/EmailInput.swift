import UIKit

final class EmailInput: TextInputView<EmailTextField> {
    var isEnabled: Bool {
        get { textInput.isEnabled }
        set {
            textInput.isEnabled = newValue
            textInput.textColor = isEnabled ? .label : .disabled2
            update()
        }
    }

    var text: String? { textInput.text }

    override func setUp() {
        textInput.addTarget(self, action: #selector(textDidChange(sender:)), for: .editingChanged)
    }

    @objc private func textDidChange(sender: UITextField) {
        onTextChanged(isValid)
    }
}

final class EmailTextField: BorderedTextField, TextInputType {
    var isValid: Bool {
        guard let text else { return false }

        return regex.firstMatch(in: text, range: .init(location: 0, length: text.count)) != nil
    }

    var fields: [UIView] { [self] }

    private let regex: NSRegularExpression = try! .init(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$", options: [.caseInsensitive])

    override init(frame: CGRect) {
        super.init(frame: frame)
        placeholder = NSLocalizedString("stytch.emailPlaceholder", value: "example@company.com", comment: "")
        autocapitalizationType = .none
        autocorrectionType = .no
        textContentType = .emailAddress
        keyboardType = .emailAddress
        background = UIColor.clear.image()
        disabledBackground = UIColor.disabled.image()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
