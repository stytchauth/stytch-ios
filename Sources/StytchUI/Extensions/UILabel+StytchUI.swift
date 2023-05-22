import UIKit

extension UILabel {
    static func makeTitleLabel(text: String? = nil) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .label
        return label
    }
}
