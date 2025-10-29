import UIKit

protocol OTPCodeEntryViewDelegate: AnyObject {
    /// Called when the user has entered all 6 digits
    func didEnterOTPCode(_ code: String)
}

class OTPCodeEntryView: UIView, UITextFieldDelegate, BackspaceDetectingTextFieldDelegate {
    weak var delegate: OTPCodeEntryViewDelegate?

    private var textFields: [BackspaceDetectingTextField] = []
    private let numberOfBoxes = 6
    private var currentIndex: Int = 0 // Tracks the current index being edited

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        // Create a stack view for text fields
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        for index in 0..<numberOfBoxes {
            let textField = BackspaceDetectingTextField()
            textField.delegate = self
            textField.backspaceDelegate = self
            textField.textAlignment = .center
            textField.keyboardType = .numberPad
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor.systemGray4.cgColor
            textField.font = UIFont.systemFont(ofSize: 24)
            textField.layer.cornerRadius = .cornerRadius
            textField.clipsToBounds = true
            textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

            textField.tag = index // Assign an index for identification

            // Add tap gesture to ensure rightmost empty box is focused
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTextFieldTap))
            textField.addGestureRecognizer(tapGesture)
            textField.isUserInteractionEnabled = true

            textFields.append(textField)
            stackView.addArrangedSubview(textField)
        }

        addSubview(stackView)

        // Constraints for the stack view
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        // Set the first text field as the initial responder
        textFields.first?.becomeFirstResponder()
    }

    @objc private func handleTextFieldTap() {
        if let firstEmptyIndex = textFields.firstIndex(where: { $0.text?.isEmpty ?? true }) {
            currentIndex = firstEmptyIndex
            textFields[firstEmptyIndex].becomeFirstResponder()
        } else {
            currentIndex = numberOfBoxes - 1
            textFields.last?.becomeFirstResponder()
        }
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let textField = textField as? BackspaceDetectingTextField else {
            return
        }

        guard let text = textField.text, text.count <= 1 else {
            textField.text = String(textField.text?.prefix(1) ?? "")
            return
        }

        if let index = textFields.firstIndex(of: textField) {
            currentIndex = index

            if text.isEmpty == false, currentIndex < numberOfBoxes - 1 {
                currentIndex += 1
                textFields[currentIndex].becomeFirstResponder()
            }
        }

        // Check if all fields are filled and notify delegate
        let code = textFields.map { $0.text ?? "" }.joined()
        if code.count == numberOfBoxes {
            delegate?.didEnterOTPCode(code)
            // Do not resignFirstResponder, allow deletions
        }
    }

    // MARK: BackspaceDetectingTextFieldDelegate

    func textFieldDidDeleteBackward(_ textField: BackspaceDetectingTextField) {
        if let index = textFields.firstIndex(of: textField) {
            currentIndex = index
            textFields[currentIndex].text = ""
            if currentIndex > 0 {
                currentIndex -= 1
                textFields[currentIndex].text = ""
                textFields[currentIndex].becomeFirstResponder()
            }
        }
    }

    // MARK: UITextFieldDelegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn _: NSRange, replacementString string: String) -> Bool {
        guard let textField = textField as? BackspaceDetectingTextField else {
            return false
        }

        // Handle pasting
        if string.count > 1 {
            // Validate that the string is a 6-digit number
            guard string.count == numberOfBoxes, string.allSatisfy(\.isNumber) else {
                return false
            }

            // Process the valid 6-digit number
            for (index, char) in string.enumerated() {
                textFields[index].text = String(char)
            }

            currentIndex = numberOfBoxes - 1
            delegate?.didEnterOTPCode(string)
            return false
        }

        // Allow input only if the current box is empty
        if textField.text?.isEmpty == false {
            return false
        }

        return string.count == 1
    }

    func clear() {
        Task { @MainActor in
            for textField in textFields {
                textField.text = ""
            }
            currentIndex = 0
            textFields.first?.becomeFirstResponder()
        }
    }
}

class BackspaceDetectingTextField: UITextField {
    weak var backspaceDelegate: BackspaceDetectingTextFieldDelegate?

    override func deleteBackward() {
        super.deleteBackward()
        backspaceDelegate?.textFieldDidDeleteBackward(self)
    }
}

protocol BackspaceDetectingTextFieldDelegate: AnyObject {
    func textFieldDidDeleteBackward(_ textField: BackspaceDetectingTextField)
}
