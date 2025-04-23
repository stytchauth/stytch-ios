import UIKit

final class OrganizationSlugInput: TextInputView<OrganizationSlugTextField> {
    var text: String? { textInput.text }

    var onReturn: (Bool) -> Void = { _ in }

    // swiftlint:disable:next overridden_super_call
    override func setUp() {
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textInput, queue: .main) { [weak self] _ in
            guard let self else { return }
            self.onTextChanged(self.isValid)
        }
        textInput.textContentType = .none
        textInput.delegate = self
        textInput.accessibilityLabel = "organizationSlugEntry"
        textInput.returnKeyType = .done
    }
}

final class OrganizationSlugTextField: BorderedTextField, TextInputType {
    var isValid: Bool {
        true
    }

    var fields: [UIView] { [self] }

    override init(frame: CGRect) {
        super.init(frame: frame)
        placeholder = LocalizationManager.stytch_b2b_organization_slug_placeholder
        autocapitalizationType = .none
        autocorrectionType = .no
        background = UIColor.clear.image()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension OrganizationSlugInput: UITextFieldDelegate {
    func textField(_: UITextField, shouldChangeCharactersIn _: NSRange, replacementString _: String) -> Bool {
        true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        onReturn(isValid)
        return true
    }
}
