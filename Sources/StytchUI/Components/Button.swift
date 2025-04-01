import UIKit

class Button: UIButton {
    enum Kind {
        case primary
        case secondary
        case tertiary
    }

    private let feedback = UIImpactFeedbackGenerator(style: .light)

    fileprivate var kind: Kind? {
        didSet {
            guard let kind else { return }
            updateColors(for: kind)
        }
    }

    override var intrinsicContentSize: CGSize {
        .init(width: UIView.noIntrinsicMetric, height: .buttonHeight)
    }

    var onTap: () -> Void = {}

    override init(frame: CGRect) {
        super.init(frame: frame)

        addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didTapButton() {
        feedback.impactOccurred()
        onTap()
    }

    private func applyConfiguration(
        contentPadding: NSDirectionalEdgeInsets,
        imageTitlePadding: CGFloat
    ) {
        var config = configuration ?? UIButton.Configuration.plain()

        config.contentInsets = contentPadding
        config.imagePadding = imageTitlePadding

        configuration = config
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            if let kind {
                updateColors(for: kind)
            }
        }
    }

    func updateColors(for kind: Kind) {
        switch kind {
        case .primary:
            setBackgroundImage(UIColor.primaryButtonDisabled.image(), for: .disabled)
            setBackgroundImage(UIColor.primaryButton.image(), for: .normal)
            setBackgroundImage(UIColor.primaryButton.withAlphaComponent(0.7).image(), for: .highlighted)
            setTitleColor(.primaryButtonText, for: .normal)
            setTitleColor(.primaryButtonTextDisabled, for: .disabled)
        case .secondary:
            setBackgroundImage(UIColor.primaryText.withAlphaComponent(0.4).image(), for: .highlighted)
            layer.borderColor = UIColor.secondaryButtonText.cgColor
        case .tertiary:
            setTitleColor(.tertiaryButton, for: .normal)
        }
    }
}

extension Button {
    static func primary(title: String, onTap: @escaping () -> Void) -> Button {
        let button = Button(type: .custom)
        button.kind = .primary
        button.onTap = onTap
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .IBMPlexSansSemiBold(size: 18)
        return button
    }

    static func secondary(image asset: ImageAsset?, title: String, onTap: @escaping () -> Void) -> Button {
        let button = Button(type: .custom)
        button.kind = .secondary
        button.setImage(asset?.image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit

        button.applyConfiguration(
            contentPadding: .zero,
            imageTitlePadding: 8
        )

        button.setAttributedTitle(
            NSAttributedString(
                string: title,
                attributes: [
                    .foregroundColor: UIColor.primaryText,
                    .font: UIFont.IBMPlexSansMedium(size: 18),
                ]
            ),
            for: .normal
        )
        button.onTap = onTap
        button.layer.borderWidth = 2 / 3
        button.layer.cornerRadius = .cornerRadius
        return button
    }

    static func tertiary(title: String, onTap: @escaping () -> Void) -> Button {
        let button = Button(type: .custom)
        button.kind = .tertiary
        button.onTap = onTap
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .IBMPlexSansSemiBold(size: 18)
        return button
    }

    static func createTextButton(
        withPlainText plainText: String,
        boldText: String? = nil,
        fontSize: CGFloat = 16,
        action: Selector,
        target: Any
    ) -> Button {
        // Create the button
        let button = Button(type: .system)

        // Create attributed text
        let attributedText = NSMutableAttributedString(string: plainText, attributes: [
            .font: UIFont.IBMPlexSansRegular(size: fontSize),
            .foregroundColor: UIColor.primaryText,
        ])

        // If boldText is provided, append it with bold style
        if let boldText = boldText {
            let boldAttributedText = NSAttributedString(string: " \(boldText)", attributes: [
                .font: UIFont.IBMPlexSansBold(size: fontSize),
                .foregroundColor: UIColor.primaryText,
            ])
            attributedText.append(boldAttributedText)
        }

        // Set the attributed title to the button
        button.setAttributedTitle(attributedText, for: .normal)

        // Allow the button's title to wrap
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center // Optional, based on desired alignment

        // Enable flexible width and height
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center

        // Add the action to the button
        button.addTarget(target, action: action, for: .touchUpInside)

        return button
    }
}
