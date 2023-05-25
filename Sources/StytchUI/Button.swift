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

    private func setInsets(
        forContentPadding contentPadding: UIEdgeInsets,
        imageTitlePadding: CGFloat
    ) {
        contentEdgeInsets = .init(
            top: contentPadding.top,
            left: contentPadding.left,
            bottom: contentPadding.bottom,
            right: contentPadding.right + imageTitlePadding
        )
        titleEdgeInsets = .init(
            top: 0,
            left: imageTitlePadding,
            bottom: 0,
            right: -imageTitlePadding
        )
        imageEdgeInsets = .init(top: 16, left: 0, bottom: 16, right: -12)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
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
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        return button
    }

    static func secondary(image asset: ImageAsset?, title: String, onTap: @escaping () -> Void) -> Button {
        let button = Button(type: .custom)
        button.kind = .secondary
        button.setImage(asset?.image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.setInsets(
            forContentPadding: .zero,
            imageTitlePadding: 8
        )
        button.setAttributedTitle(
            NSAttributedString(
                string: title,
                attributes: [
                    .foregroundColor: UIColor.primaryText,
                    .font: UIFont.systemFont(ofSize: 18, weight: .medium),
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
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        return button
    }
}
