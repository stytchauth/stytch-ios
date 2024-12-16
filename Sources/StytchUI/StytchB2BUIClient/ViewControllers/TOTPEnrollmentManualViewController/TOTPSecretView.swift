import StytchCore
import UIKit

protocol TOTPSecretViewDelegate: AnyObject {
    func didCopyTOTPSecret()
}

class TOTPSecretView: UIView {
    weak var delegate: TOTPSecretViewDelegate?
    private let textLabel = UILabel()
    private let copyButton = UIButton(type: .system)

    init(secret: String) {
        super.init(frame: .zero)
        setupView()
        configure(with: secret)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        // Main container
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
        addSubview(containerView)

        // Text label
        textLabel.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)
        textLabel.textColor = .label
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(textLabel)

        // Copy button
        copyButton.setImage(UIImage(named: "copy", in: .module, compatibleWith: nil), for: .normal)
        copyButton.tintColor = .systemGray
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.addTarget(self, action: #selector(copyToClipboard), for: .touchUpInside)
        containerView.addSubview(copyButton)

        // Layout constraints
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 60),

            // Text label
            textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            textLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            // Copy button
            copyButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            copyButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            copyButton.leadingAnchor.constraint(greaterThanOrEqualTo: textLabel.trailingAnchor, constant: 10),
        ])
    }

    func configure(with secret: String) {
        textLabel.text = secret
    }

    @objc private func copyToClipboard() {
        UIPasteboard.general.string = textLabel.text
        delegate?.didCopyTOTPSecret()
    }
}
