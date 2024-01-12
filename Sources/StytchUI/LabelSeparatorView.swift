import UIKit

final class LabelSeparatorView: UIView {
    var text: String? {
        get { label.text }
        set { label.text = newValue }
    }

    private let leadingBar = makeSeparatorBar()

    private let label = UILabel()

    private let trailingBar = makeSeparatorBar()

    override var intrinsicContentSize: CGSize {
        label.intrinsicContentSize
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(leadingBar)
        addSubview(label)
        addSubview(trailingBar)

        subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        label.textColor = .placeholderText

        NSLayoutConstraint.activate([
            leadingBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            leadingBar.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -30),
            leadingBar.centerYAnchor.constraint(equalTo: centerYAnchor),
            leadingBar.heightAnchor.constraint(equalToConstant: 1),
            trailingBar.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 30),
            trailingBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            trailingBar.centerYAnchor.constraint(equalTo: centerYAnchor),
            trailingBar.heightAnchor.constraint(equalToConstant: 1),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func makeSeparatorBar() -> UIView {
        let view = UIView()
        view.backgroundColor = .placeholderText
        return view
    }
}

extension LabelSeparatorView {
    static func orSeparator() -> Self {
        let view = Self()
        view.text = NSLocalizedString("stytch.orSeparator", value: "or", comment: "")
        view.accessibilityLabel = "orSeparator"
        return view
    }
}
