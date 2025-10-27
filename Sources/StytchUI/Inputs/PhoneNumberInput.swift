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

    var countrySelectorButton = CountrySelectorButton()

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

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Fixed width for the country selector button
            countrySelectorButton.widthAnchor.constraint(equalToConstant: 100),
        ] + stackView.arrangedSubviews.map { view in
            view.heightAnchor.constraint(equalToConstant: 42)
        })

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
        countrySelectorButton.updateCountryCode(countryCode)
    }
}

private extension NSTextAttachment {
    func setImageHeight(height: CGFloat) {
        guard let image = image else { return }
        let ratio = image.size.width / image.size.height

        bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: ratio * height, height: height)
    }
}

final class CountrySelectorButton: UIButton {
    private let titleLabelContainer = UILabel()
    private let chevronImageView = UIImageView()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        titleLabelContainer.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabelContainer.textColor = .label

        chevronImageView.image = UIImage(systemName: "chevron.down")
        chevronImageView.tintColor = .secondaryLabel
        chevronImageView.contentMode = .scaleAspectFit

        addSubview(titleLabelContainer)
        addSubview(chevronImageView)

        titleLabelContainer.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabelContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabelContainer.centerYAnchor.constraint(equalTo: centerYAnchor),

            chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            chevronImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 16),
            chevronImageView.heightAnchor.constraint(equalToConstant: 16),
        ])

        layer.cornerRadius = .cornerRadius
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor
    }

    func updateCountryCode(_ code: UInt64) {
        titleLabelContainer.text = "+\(code)"
    }
}
