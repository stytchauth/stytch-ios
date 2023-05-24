import UIKit

class Button: UIButton {
    private let feedback = UIImpactFeedbackGenerator(style: .light)

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
}

extension Button {
    static func primary(title: String, onTap: @escaping () -> Void) -> Button {
        let button = Button(type: .custom)
        button.onTap = onTap
        button.setBackgroundImage(UIColor.disabled.image(), for: .disabled)
        button.setBackgroundImage(UIColor.brand.image(), for: .normal)
        button.setBackgroundImage(UIColor.brand.withAlphaComponent(0.7).image(), for: .highlighted)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.placeholder, for: .disabled)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        return button
    }

    static func secondary(image asset: ImageAsset?, title: String, onTap: @escaping () -> Void) -> Button {
        let button = Button(type: .custom)
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
                    .foregroundColor: UIColor.label,
                    .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                ]
            ),
            for: .normal
        )
        button.setBackgroundImage(UIColor.black.withAlphaComponent(0.4).image(), for: .highlighted)
        button.onTap = onTap
        button.layer.borderColor = UIColor.label.cgColor
        button.layer.borderWidth = 2 / 3
        button.layer.cornerRadius = .cornerRadius
        return button
    }

    static func tertiary(title: String, onTap: @escaping () -> Void) -> Button {
        let button = Button(type: .custom)
        button.onTap = onTap
        button.setTitleColor(.brand, for: .normal)
        button.setTitleColor(.systemGray, for: .highlighted)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        return button
    }
}
