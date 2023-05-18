import UIKit

final class EmailInput: TextInputView<EmailTextField> {
    var text: String? { textInput.text }

    override func setUp() {
        textInput.addTarget(self, action: #selector(textDidChange(sender:)), for: .editingChanged)
    }

    @objc private func textDidChange(sender: UITextField) {
        onTextChanged(isValid)
    }
}

final class EmailTextField: UITextField, TextInputType {
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
        layer.borderColor = UIColor.placeholder.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = .cornerRadius
        leftView = UIView(frame: .init(x: 0, y: 0, width: 10, height: 10))
        leftViewMode = .always
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
