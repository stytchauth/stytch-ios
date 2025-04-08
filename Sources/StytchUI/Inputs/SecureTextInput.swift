import StytchCore
import SwiftUI
import UIKit

final class SecureTextInput: TextInputView<SecureTextField> {
    var onReturn: (Bool) -> Void = { _ in }

    var text: String? {
        textInput.text
    }

    var imageName: String {
        textInput.isSecureTextEntry ? "eye.slash" : "eye"
    }

    private let zxcvbnIndicator = ZXCVBNIndicator(state: ZXCVBNState())
    private lazy var zxcvbnIndicatorView: UIView = UIHostingController(rootView: self.zxcvbnIndicator).view

    private let ludsIndicator = LUDSIndicator(state: LUDSFeedbackState())
    private lazy var ludsIndicatorView: UIView = UIHostingController(rootView: self.ludsIndicator).view

    private lazy var toggleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .secondaryText
        button.addTarget(self, action: #selector(toggleSecureEntry), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 12.5),
        ])
        return button
    }()

    private(set) lazy var feedback: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 2
        return view
    }()

    // swiftlint:disable:next overridden_super_call
    override func setUp() {
        NotificationCenter.default.addObserver(
            forName: UITextField.textDidChangeNotification,
            object: textInput,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.onTextChanged(self.isValid)
        }

        feedback.addArrangedSubview(zxcvbnIndicatorView)
        feedback.addArrangedSubview(ludsIndicatorView)
        supplementaryView = feedback
        feedback.isHidden = true
        textInput.delegate = self
        textInput.returnKeyType = .done

        textInput.rightView = toggleButton
        textInput.rightViewMode = .always
    }

    @objc private func toggleSecureEntry() {
        textInput.isSecureTextEntry.toggle()
        toggleButton.setImage(UIImage(systemName: imageName), for: .normal)

        // Optional fix for cursor jump
        if let text = textInput.text, textInput.isFirstResponder {
            textInput.deleteBackward()
            textInput.insertText(text + " ")
            textInput.deleteBackward()
        }
    }

    func setZXCVBNFeedback(suggestions: [String]?, warning: String?, score: Int) {
        Task { @MainActor in
            feedback.isHidden = false
            zxcvbnIndicatorView.isHidden = false
            ludsIndicatorView.isHidden = true
            zxcvbnIndicator.setFeedback(suggestions: suggestions, warning: warning, score: score)
            didSetFeedback()
        }
    }

    func setLUDSFeedback(ludsRequirement: LudsRequirement, breached: Bool = false, passwordConfig: PasswordConfig? = nil) {
        Task { @MainActor in
            feedback.isHidden = false
            zxcvbnIndicatorView.isHidden = true
            ludsIndicatorView.isHidden = false
            ludsIndicator.setFeedback(feedback: ludsRequirement, breached: breached, passwordConfig: passwordConfig)
            didSetFeedback()
        }
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

final class SecureTextField: BorderedTextField, TextInputType {
    var isValid: Bool {
        text?.isEmpty == false
    }

    var fields: [UIView] {
        [self]
    }

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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        onReturn(isValid)
        return true
    }
}
