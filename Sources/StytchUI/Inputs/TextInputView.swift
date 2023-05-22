import UIKit

protocol TextInputType: UIView {
    var isValid: Bool { get }
    var fields: [UIView] { get }
    var isEnabled: Bool { get }
}

class TextInputView<TextInput: TextInputType>: UIView {
    enum Feedback {
        case error(String)
        case normal(String)
    }

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

    private let feedbackLabel: UILabel = {
        let label = UILabel()
        label.textColor = .error
        label.isHidden = true
        return label
    }()

    final override var intrinsicContentSize: CGSize {
        stackView.systemLayoutSizeFitting(
            .init(width: bounds.width, height: .infinity)
        )
    }

    private var feedback: Feedback?

    override init(frame: CGRect) {
        super.init(frame: frame)
        stackView.addArrangedSubview(textInput)
        stackView.addArrangedSubview(feedbackLabel)

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

    final func setFeedback(_ feedback: Feedback?) {
        self.feedback = feedback
        switch feedback {
        case let .error(text), let .normal(text):
            feedbackLabel.text = text
        case .none:
            feedbackLabel.text = nil
        }
        feedbackLabel.isHidden = feedback == nil
        update()
        invalidateIntrinsicContentSize()
    }

    func update() {
        let borderColor: UIColor
        switch (feedback, textInput.isEnabled) {
        case (.error, _):
            borderColor = .error
            feedbackLabel.textColor = .error
        case (_, true):
            borderColor = .placeholder
            feedbackLabel.textColor = .brand
        case (_, false):
            borderColor = .lightBorder
            feedbackLabel.textColor = .brand
        }
        textInput.fields.forEach { view in
            view.layer.borderColor = borderColor.cgColor
        }
    }
}
