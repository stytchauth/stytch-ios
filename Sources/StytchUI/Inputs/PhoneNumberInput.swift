import PhoneNumberKit
import UIKit

final class PhoneNumberInput: TextInputView<PhoneNumberInputContainer> {
    var onButtonPressed: (PhoneNumberKit) -> Void = { _ in }

    var phoneNumberE164: String? {
        isValid ? textField.phoneNumber.map { "+\($0.countryCode)\($0.nationalNumber)" } : nil
    }

    var formattedPhoneNumber: String? {
        isValid ? textField.phoneNumber.map { "+\($0.countryCode) \($0.numberString)"} : nil
    }

    var phoneNumberKit: PhoneNumberKit { textField.phoneNumberKit }

    private var textField: PhoneNumberTextField { textInput.textField }

    override func setUp() {
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { [weak self] notification in
            guard let self else { return }
            self.onTextChanged(self.isValid)
        }

        textInput.countrySelectorButton.addTarget(self, action: #selector(didTapButton(sender:)), for: .primaryActionTriggered)
        PhoneNumberKit.CountryCodePicker.forceModalPresentation = true
    }

    @objc private func didTapButton(sender: UIButton) {
        onButtonPressed(textField.phoneNumberKit)
    }
}

extension PhoneNumberInput: CountryCodePickerDelegate {
    func countryCodePickerViewControllerDidPickCountry(_ country: CountryCodePickerViewController.Country) {
        print("googogole")
        textInput.countryCodePickerViewControllerDidPickCountry(country)
    }
}

final class PhoneNumberInputContainer: UIView, TextInputType {
    var isValid: Bool { textField.isValidNumber }

    var fields: [UIView] { [textField, countrySelectorButton] }

    fileprivate lazy var textField: PhoneNumberTextField = {
        let field = PhoneNumberTextField()
        field.textContentType = .telephoneNumber
        field.withDefaultPickerUI = true
        field.withPrefix = false
        field.withExamplePlaceholder = true
        field.layer.borderColor = UIColor.placeholder.cgColor
        field.layer.borderWidth = 1
        field.layer.cornerRadius = .cornerRadius
        let view = UIView(frame: .init(x: 0, y: 0, width: 10, height: 10))
        field.leftView = view
        field.leftViewMode = .always
        return field
    }()

    fileprivate lazy var countrySelectorButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.contentEdgeInsets = .init(top: 0, left: 14, bottom: 0, right: 14)
        button.layer.borderColor = UIColor.placeholder.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = .cornerRadius
        return button
    }()

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 8
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        countrySelectorButton.setContentHuggingPriority(.required, for: .horizontal)

        stackView.addArrangedSubview(countrySelectorButton)
        stackView.addArrangedSubview(textField)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate(
            [
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ] + stackView.arrangedSubviews.map { view in
                view.heightAnchor.constraint(equalToConstant: 42)
            }
        )

        updateButtonTitle()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func countryCodePickerViewControllerDidPickCountry(_ country: CountryCodePickerViewController.Country) {
        textField.countryCodePickerViewControllerDidPickCountry(country)
        updateButtonTitle()
    }

    private func updateButtonTitle() {
        guard let countryCode = textField.phoneNumberKit.countryCode(for: textField.currentRegion) else { return }

        let attributedText = NSMutableAttributedString(string: "+ \(countryCode)  ")
        let attachment = NSTextAttachment(image: UIImage(systemName: "chevron.down")!)
        attachment.setImageHeight(height: 10)
        attributedText.append(NSAttributedString(attachment: attachment))
        countrySelectorButton.setAttributedTitle(attributedText, for: .normal)
    }
}

private extension NSTextAttachment {
    func setImageHeight(height: CGFloat) {
        guard let image = image else { return }
        let ratio = image.size.width / image.size.height

        bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: ratio * height, height: height)
    }
}
