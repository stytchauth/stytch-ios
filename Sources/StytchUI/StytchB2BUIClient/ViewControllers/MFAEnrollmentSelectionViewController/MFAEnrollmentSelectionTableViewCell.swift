import StytchCore
import UIKit

class MFAEnrollmentSelectionTableViewCell: UITableViewCell {
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.IBMPlexSansRegular(size: 16)
        label.textColor = .primaryText
        return label
    }()

    private let disclosureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .gray
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Add subviews
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(disclosureImageView)

        // Add constraints
        NSLayoutConstraint.activate([
            // Description Label
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            descriptionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            // Disclosure Indicator
            disclosureImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            disclosureImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            disclosureImageView.widthAnchor.constraint(equalToConstant: 12),
            disclosureImageView.heightAnchor.constraint(equalToConstant: 12),
        ])

        backgroundColor = .background
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with mfaMethod: StytchB2BClient.MfaMethod, image _: UIImage?) {
        if mfaMethod == .sms {
            descriptionLabel.text = "Text me a code"
        } else {
            descriptionLabel.text = "Use an authenticator app"
        }
    }
}
