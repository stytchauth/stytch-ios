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

    private let iconLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.backgroundColor = .lightGray // Placeholder background color
        label.textColor = .white
        label.layer.cornerRadius = 16
        label.clipsToBounds = true
        label.font = UIFont.IBMPlexSansBold(size: 16)
        label.isHidden = true // Initially hidden
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.IBMPlexSansRegular(size: 16)
        label.textColor = .primaryText
        return label
    }()

    private let joinLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Join"
        label.font = UIFont.IBMPlexSansRegular(size: 16)
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

        backgroundColor = .background

        // Add subviews
        contentView.addSubview(iconImageView)
        contentView.addSubview(iconLabel)
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

            // Icon Label (overlaps ImageView)
            iconLabel.leadingAnchor.constraint(equalTo: iconImageView.leadingAnchor),
            iconLabel.topAnchor.constraint(equalTo: iconImageView.topAnchor),
            iconLabel.widthAnchor.constraint(equalTo: iconImageView.widthAnchor),
            iconLabel.heightAnchor.constraint(equalTo: iconImageView.heightAnchor),

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

    func configure(with discoveredOrganization: StytchB2BClient.DiscoveredOrganization) {
        descriptionLabel.text = discoveredOrganization.organization.name

        if let logoUrl = discoveredOrganization.organization.logoUrl {
            loadImage(logoUrl)
        } else {
            setInitialLabel(with: discoveredOrganization.organization.name)
        }

        configureJoinLabel(for: discoveredOrganization.membership.type)
    }

    private func loadImage(_ logoUrl: URL) {
        // Hide the label since we have an image
        iconLabel.isHidden = true
        iconImageView.isHidden = false

        let dataTask = URLSession.shared.dataTask(with: logoUrl) { data, _, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.iconImageView.image = UIImage(data: data)
            }
        }
        dataTask.resume()
    }

    private func setInitialLabel(with name: String?) {
        // Hide the image view since we are showing a label
        iconImageView.isHidden = true
        iconLabel.isHidden = false

        if let firstInitial = name?.first {
            iconLabel.text = String(firstInitial).uppercased()
        } else {
            iconLabel.text = ""
        }
    }

    private func configureJoinLabel(for membershipType: StytchB2BClient.MembershipType) {
        switch membershipType {
        case .activeMember:
            joinLabel.isHidden = true
        case .invitedMember:
            joinLabel.text = "Accept Invite"
        case .pendingMember, .eligibleToJoinByEmailDomain, .eligibleToJoinByOauthTenant:
            joinLabel.text = "Join"
        }
    }
}
