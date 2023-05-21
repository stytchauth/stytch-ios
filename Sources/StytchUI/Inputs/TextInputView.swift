import UIKit

protocol TextInputType: UIView {
    var isValid: Bool { get }
    var fields: [UIView] { get }
    var isEnabled: Bool { get }
}

class TextInputView<TextInput: TextInputType>: UIView {
    var onTextChanged: (Bool) -> Void {
        get { _onTextChanged }
        set {
            _onTextChanged = { [unowned self] isValid in
                if isValid, !hasBeenValid {
                    hasBeenValid = true
                }
                newValue(isValid)
            }
        }
    }

    private var _onTextChanged: (Bool) -> Void = { _ in }

    final var isValid: Bool { textInput.isValid }

    final private(set) var hasBeenValid = false

    let textInput: TextInput = .init()

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 2
        return view
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .error
        label.isHidden = true
        return label
    }()

    final override var intrinsicContentSize: CGSize {
        stackView.systemLayoutSizeFitting(.init(width: bounds.width, height: .infinity))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        stackView.addArrangedSubview(textInput)
        stackView.addArrangedSubview(errorLabel)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate(
            [
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
                textInput.widthAnchor.constraint(equalTo: stackView.widthAnchor)
            ] + textInput.fields.map { view in
                view.heightAnchor.constraint(equalToConstant: 42)
            }
        )

        setUp()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUp() {}

    final func setErrorText(_ text: String?) {
        errorLabel.text = text
        errorLabel.isHidden = text == nil
        updateBorderColor()
        invalidateIntrinsicContentSize()
    }

    func updateBorderColor() {
        let borderColor: UIColor
        switch (errorLabel.isHidden, textInput.isEnabled) {
        case (false, _):
            borderColor = .error
        case (true, true):
            borderColor = .placeholder
        case (true, false):
            borderColor = .lightBorder
        }
        textInput.fields.forEach { view in
            view.layer.borderColor = borderColor.cgColor
        }
    }
}
