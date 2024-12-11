import UIKit

extension UILabel {
    static func makeTitleLabel(text: String? = nil) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .primaryText
        return label
    }

    static func makeSubtitleLabel(text: String? = nil) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .secondaryText
        return label
    }

    static func makeFooterLabel(text: String? = nil) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryText
        return label
    }

    static func makeEmailInputLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryText
        label.text = NSLocalizedString("stytch.emailInputLabel", value: "Email", comment: "")
        return label
    }

    static func makePasswordInputLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryText
        label.text = NSLocalizedString("stytch.passwordInputLabel", value: "Password", comment: "")
        return label
    }

    static func makeComboLabel(
        withPlainText plainText: String,
        boldText: String? = nil,
        fontSize: CGFloat = 16,
        alignment: NSTextAlignment = .left
    ) -> UILabel {
        // Create the label
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = alignment

        // Create attributed text
        let attributedText = NSMutableAttributedString(string: plainText, attributes: [
            .font: UIFont.systemFont(ofSize: fontSize),
        ])

        // If boldText is provided, append it with bold style
        if let boldText = boldText {
            let boldAttributedText = NSAttributedString(string: " \(boldText)", attributes: [
                .font: UIFont.boldSystemFont(ofSize: fontSize),
            ])
            attributedText.append(boldAttributedText)
        }

        // Set the attributed text to the label
        label.attributedText = attributedText

        return label
    }
}
