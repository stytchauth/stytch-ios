import UIKit

// swiftlint:disable type_contents_order

class RecoveryCodesListView: UIView {
    var codes: [String] = []

    init(codes: [String]) {
        self.codes = codes
        super.init(frame: .zero)
        setupView(codes: codes)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView(codes: codes)
    }

    // Override intrinsicContentSize to fit content height
    override var intrinsicContentSize: CGSize {
        // Calculate the height based on the number of codes, spacing, and padding
        let numberOfCodes = codes.count
        let labelHeight: CGFloat = 20 // Estimated height of each label
        let spacing: CGFloat = 8 // Stack view spacing
        let padding: CGFloat = 32 // Top + bottom padding (16 + 16)
        let totalHeight = CGFloat(numberOfCodes) * labelHeight + CGFloat(numberOfCodes - 1) * spacing + padding
        return CGSize(width: UIView.noIntrinsicMetric, height: totalHeight)
    }
}

extension RecoveryCodesListView {
    private func setupView(codes: [String]) {
        // Set up self
        backgroundColor = UIColor.systemGray6
        layer.cornerRadius = .cornerRadius
        translatesAutoresizingMaskIntoConstraints = false

        // Create a stack view
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill // Ensure full width
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        // Add constraints to stack view
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])

        // Add labels to the stack view
        for code in codes {
            let label = UILabel()
            label.text = code
            label.textColor = .primaryText
            label.textAlignment = .center
            label.font = UIFont.IBMPlexSansRegular(size: 16)
            label.numberOfLines = 1 // Ensure single line per code
            stackView.addArrangedSubview(label)
        }

        layoutMargins = .default
    }
}
