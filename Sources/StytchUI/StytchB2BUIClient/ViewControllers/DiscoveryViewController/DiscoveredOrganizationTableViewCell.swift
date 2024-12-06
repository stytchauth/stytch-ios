import StytchCore
import UIKit

class DiscoveredOrganizationTableViewCell: UITableViewCell {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16 // Assuming it's a circular icon
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray // Placeholder background color
        return imageView
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()

    private let joinLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Join"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .systemBlue
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
        contentView.addSubview(iconImageView)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(joinLabel)
        contentView.addSubview(disclosureImageView)

        // Add constraints
        NSLayoutConstraint.activate([
            // Icon ImageView
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),

            // Description Label
            descriptionLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            descriptionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            // Join Label
            joinLabel.trailingAnchor.constraint(equalTo: disclosureImageView.leadingAnchor, constant: -8),
            joinLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            // Disclosure Indicator
            disclosureImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            disclosureImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            disclosureImageView.widthAnchor.constraint(equalToConstant: 12),
            disclosureImageView.heightAnchor.constraint(equalToConstant: 12),
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with discoveredOrganization: StytchB2BClient.DiscoveredOrganization, image: UIImage?) {
        descriptionLabel.text = discoveredOrganization.organization.name
        iconImageView.image = image // Set image for the icon
    }
}
