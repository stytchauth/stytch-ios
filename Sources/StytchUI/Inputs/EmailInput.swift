import UIKit

final class EmailInput: TextInputView<EmailTextField> {
    var onReturn: (Bool) -> Void = { _ in }
    var shouldResignFirstResponderOnReturn = true

    var isEnabled: Bool {
        get { textInput.isEnabled }
        set {
            textInput.isEnabled = newValue
            textInput.textColor = isEnabled ? .primaryText : .disabledText
            update()
        }
    }

    var text: String? { textInput.text }

    override func setUp() {
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textInput, queue: .main) { [weak self] _ in
            guard let self else { return }
            self.onTextChanged(self.isValid)
        }
        textInput.delegate = self
        textInput.returnKeyType = .done
    }

    func updateText(_ text: String) {
        Task { @MainActor in
            textInput.text = text
        }
    }

    func setReturnKeyType(returnKeyType: UIReturnKeyType) {
        Task { @MainActor in
            textInput.returnKeyType = returnKeyType
        }
    }

    func assignFirstResponder() {
        Task { @MainActor in
            textInput.becomeFirstResponder()
        }
    }
}

extension EmailInput: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if shouldResignFirstResponderOnReturn == true {
            textField.resignFirstResponder()
        }
        onReturn(isValid)
        return true
    }
}

final class EmailTextField: BorderedTextField, TextInputType {
    var isValid: Bool {
        guard let text else { return false }

        return regex.firstMatch(in: text, range: .init(location: 0, length: text.count)) != nil
    }

    var fields: [UIView] { [self] }

    // swiftlint:disable:next force_try
    private let regex: NSRegularExpression = try! .init(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$", options: [.caseInsensitive])

    override init(frame: CGRect) {
        super.init(frame: frame)
        placeholder = LocalizationManager.stytch_b2c_email_placeholder
        autocapitalizationType = .none
        autocorrectionType = .no
        textContentType = .emailAddress
        keyboardType = .emailAddress
        background = UIColor.clear.image()
        disabledBackground = UIColor.textfieldDisabled.image()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
