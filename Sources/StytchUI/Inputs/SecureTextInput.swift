import StytchCore
import SwiftUI
import UIKit

final class SecureTextInput: TextInputView<SecureTextField> {
    private(set) lazy var feedback: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 2
        return view
    }()

    private let zxcvbnIndicator = ZXCVBNIndicator(state: ZXCVBNState())
    private lazy var zxcvbnIndicatorView: UIView = UIHostingController(rootView: self.zxcvbnIndicator).view

    private let ludsIndicator = LUDSIndicator(state: LUDSFeedbackState())
    private lazy var ludsIndicatorView: UIView = UIHostingController(rootView: self.ludsIndicator).view

    var text: String? { textInput.text }

    var onReturn: (Bool) -> Void = { _ in }

    // swiftlint:disable:next overridden_super_call
    override func setUp() {
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textInput, queue: .main) { [weak self] _ in
            guard let self else { return }
            self.onTextChanged(self.isValid)
        }
        feedback.addArrangedSubview(zxcvbnIndicatorView)
        feedback.addArrangedSubview(ludsIndicatorView)
        supplementaryView = feedback
        feedback.isHidden = true
        textInput.delegate = self
        textInput.returnKeyType = .done
    }

    func setZXCVBNFeedback(suggestions: [String]?, warning: String?, score: Int) {
        feedback.isHidden = false
        zxcvbnIndicatorView.isHidden = false
        ludsIndicatorView.isHidden = true
        zxcvbnIndicator.setFeedback(suggestions: suggestions, warning: warning, score: score)
        didSetFeedback()
    }

    func setLUDSFeedback(ludsRequirement: LudsRequirement, breached: Bool = false, passwordConfig: PasswordConfig? = nil) {
        feedback.isHidden = false
        zxcvbnIndicatorView.isHidden = true
        ludsIndicatorView.isHidden = false
        ludsIndicator.setFeedback(feedback: ludsRequirement, breached: breached, passwordConfig: passwordConfig)
        didSetFeedback()
    }

    func setReturnKeyType(returnKeyType: UIReturnKeyType) {
        textInput.returnKeyType = returnKeyType
    }

    func assignFirstResponder() {
        textInput.becomeFirstResponder()
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        onReturn(isValid)
        return true
    }
}
