import UIKit

extension UILabel {
    static func makeTitleLabel(text: String? = nil) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = .IBMPlexSansSemiBold(size: 24)
        label.textColor = .primaryText
        return label
    }

    static func makeSubtitleLabel(text: String? = nil) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = .IBMPlexSansRegular(size: 18)
        label.textColor = .secondaryText
        return label
    }

    static func makeFooterLabel(text: String? = nil) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = .IBMPlexSansRegular(size: 14)
        label.textColor = .secondaryText
        return label
    }

    static func makeEmailInputLabel() -> UILabel {
        let label = UILabel()
        label.font = .IBMPlexSansRegular(size: 14)
        label.textColor = .secondaryText
        label.text = LocalizationManager.stytch_email_input_title
        return label
    }

    static func makePasswordInputLabel() -> UILabel {
        let label = UILabel()
        label.font = .IBMPlexSansRegular(size: 14)
        label.textColor = .secondaryText
        label.text = LocalizationManager.stytch_password_input_label
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
            .font: UIFont.IBMPlexSansRegular(size: fontSize),
        ])

        // If boldText is provided, append it with bold style
        if let boldText = boldText {
            let boldAttributedText = NSAttributedString(string: " \(boldText)", attributes: [
                .font: UIFont.IBMPlexSansBold(size: fontSize),
            ])
            attributedText.append(boldAttributedText)
        }

        // Set the attributed text to the label
        label.attributedText = attributedText

        return label
    }
}
