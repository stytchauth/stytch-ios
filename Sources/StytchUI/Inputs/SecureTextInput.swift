import UIKit

final class SecureTextInput: TextInputView<SecureTextField> {
    private(set) lazy var progressBar: ProgressBar = .init()

    var text: String? { textInput.text }

    var onReturn: (Bool) -> Void = { _ in }

    // swiftlint:disable:next overridden_super_call
    override func setUp() {
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textInput, queue: .main) { [weak self] _ in
            guard let self else { return }
            self.onTextChanged(self.isValid)
        }
        supplementaryView = progressBar
        progressBar.isHidden = true
        textInput.delegate = self
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
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SecureTextInput: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        onReturn(isValid)
        return true
    }
}
