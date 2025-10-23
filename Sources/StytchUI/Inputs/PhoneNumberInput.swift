import PhoneNumberKit
import UIKit

final class PhoneNumberInput: TextInputView<PhoneNumberInputContainer> {
    var onButtonPressed: (PhoneNumberUtility) -> Void = { _ in }

    var onReturn: (Bool) -> Void = { _ in }

    var phoneNumberE164: String? {
        isValid ? textField.phoneNumber.map { "+\($0.countryCode)\($0.nationalNumber)" } : nil
    }

    var formattedPhoneNumber: String? {
        isValid ? textField.phoneNumber.map { "+\($0.countryCode) \($0.numberString)" } : nil
    }

    var phoneNumberUtility: PhoneNumberUtility { textField.utility }

    private var textField: PhoneNumberTextField { textInput.textField }

    override func setUp() {
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { [weak self] _ in
            guard let self else { return }
            self.onTextChanged(self.isValid)
        }

        textInput.countrySelectorButton.addTarget(self, action: #selector(didTapButton(sender:)), for: .primaryActionTriggered)
        PhoneNumberKit.CountryCodePicker.forceModalPresentation = true
        textInput.textField.delegate = self
        textInput.textField.returnKeyType = .done
    }

    @objc private func didTapButton(sender _: UIButton) {
        onButtonPressed(textField.utility)
    }

    func setReturnKeyType(returnKeyType: UIReturnKeyType) {
        Task { @MainActor in
            textInput.textField.returnKeyType = returnKeyType
        }
    }

    func assignFirstResponder() {
        Task { @MainActor in
            textInput.textField.becomeFirstResponder()
        }
    }
}

extension PhoneNumberInput: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        onReturn(isValid)
        return true
    }
}

extension PhoneNumberInput: CountryCodePickerDelegate {
    func countryCodePickerViewControllerDidPickCountry(_ country: CountryCodePickerViewController.Country) {
        textInput.countryCodePickerViewControllerDidPickCountry(country)
    }
}

final class PhoneNumberInputContainer: UIView, TextInputType {
    var isEnabled: Bool { textField.isEnabled }

    var isValid: Bool { textField.isValidNumber }

    var fields: [UIView] { [textField, countrySelectorButton] }

    fileprivate lazy var textField: PhoneNumberTextField = {
        let field = PhoneNumberTextField()
        field.textContentType = .telephoneNumber
        field.withDefaultPickerUI = true
        field.withPrefix = false
        field.withExamplePlaceholder = true
        field.applyBorderedStyle()
        return field
    }()

    fileprivate lazy var countrySelectorButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "" // Set dynamically as needed
        config.baseForegroundColor = .label
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)

        let button = UIButton(configuration: config, primaryAction: nil)
        button.titleLabel?.font = .IBMPlexSansRegular(size: 18)
        button.translatesAutoresizingMaskIntoConstraints = false

        // Custom border & corner styling since UIButton.Configuration doesn’t support it directly
        button.layer.borderColor = UIColor.placeholderText.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = .cornerRadius
        button.layer.masksToBounds = true

        return button
    }()

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 8
        view.accessibilityLabel = "phoneNumberEntry"
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
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func countryCodePickerViewControllerDidPickCountry(_ country: CountryCodePickerViewController.Country) {
        textField.countryCodePickerViewControllerDidPickCountry(country)
        updateButtonTitle()
    }

    private func updateButtonTitle() {
        guard let countryCode = textField.utility.countryCode(for: textField.currentRegion) else { return }

        let attributedText = NSMutableAttributedString(string: "+ \(countryCode)  ")
        if let image = UIImage(systemName: "chevron.down") {
            let attachment = NSTextAttachment(image: image)
            attachment.setImageHeight(height: 10)
            attributedText.append(NSAttributedString(attachment: attachment))
        }
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
