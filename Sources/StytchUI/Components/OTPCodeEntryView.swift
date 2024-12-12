import UIKit

protocol OTPCodeEntryViewDelegate: AnyObject {
    /// Called when the user has entered all 6 digits
    func didEnterOTPCode(_ code: String)
}

class OTPCodeEntryView: UIView, UITextFieldDelegate {
    weak var delegate: OTPCodeEntryViewDelegate?

    private let hiddenTextField = UITextField()
    private var digitLabels: [UILabel] = []
    private let numberOfBoxes = 6

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        // Configure hidden text field
        hiddenTextField.keyboardType = .numberPad
        hiddenTextField.textContentType = .oneTimeCode
        hiddenTextField.delegate = self
        hiddenTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        addSubview(hiddenTextField)

        // Create a stack view for digit boxes
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        for _ in 0..<numberOfBoxes {
            let label = UILabel()
            label.textAlignment = .center
            label.layer.borderWidth = 1
            label.layer.borderColor = UIColor.gray.cgColor
            label.font = UIFont.IBMPlexSansRegular(size: 24)
            label.text = ""
            label.layer.cornerRadius = 8
            label.clipsToBounds = true
            digitLabels.append(label)
            stackView.addArrangedSubview(label)
        }

        addSubview(stackView)

        // Constraints for the stack view
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        // Add tap gesture to bring up the keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(startEditing))
        addGestureRecognizer(tapGesture)
    }

    func fillCode(code: String) {
        hiddenTextField.text = code
        updateLabels()
    }

    @objc func startEditing() {
        hiddenTextField.becomeFirstResponder()
    }

    @objc private func textFieldDidChange() {
        updateLabels()
    }

    func updateLabels() {
        guard let text = hiddenTextField.text, text.count <= numberOfBoxes else {
            hiddenTextField.text = String(hiddenTextField.text?.prefix(numberOfBoxes) ?? "")
            return
        }

        // Update each label with the corresponding digit
        for boxIndex in 0..<numberOfBoxes {
            if boxIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: boxIndex)
                digitLabels[boxIndex].text = String(text[index])
            } else {
                digitLabels[boxIndex].text = ""
            }
        }

        // Notify delegate when all digits are entered
        if text.count == numberOfBoxes {
            delegate?.didEnterOTPCode(text)
            hiddenTextField.resignFirstResponder()
        }
    }

    /// Clears all entered digits
    func clear() {
        hiddenTextField.text = ""
        for label in digitLabels {
            label.text = ""
        }
    }
}

extension String {
    var isNumber: Bool {
        let characters = CharacterSet.decimalDigits
        return CharacterSet(charactersIn: self).isSubset(of: characters)
    }
}
