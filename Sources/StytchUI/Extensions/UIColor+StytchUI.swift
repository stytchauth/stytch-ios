import UIKit

extension UIColor {
    static let brand: UIColor = .init(red: 0.10, green: 0.19, blue: 0.24, alpha: 1.00)
    static let secondary: UIColor = .init(red: 0.36, green: 0.45, blue: 0.49, alpha: 1.00)
    static let placeholder: UIColor = .init(red: 0.68, green: 0.74, blue: 0.77, alpha: 1.00)
    static let error: UIColor = .init(red: 0.55, green: 0.07, blue: 0.08, alpha: 1.00)
    static let disabled: UIColor = .init(red: 0.95, green: 0.96, blue: 0.96, alpha: 1.00)
    static let lightBorder: UIColor = .init(red: 0.90, green: 0.91, blue: 0.92, alpha: 1.00)
}

extension UIColor {
    func image(
        size: CGSize = CGSize(width: 2 * .cornerRadius, height: 2 * .cornerRadius),
        cornerRadius: CGFloat = .cornerRadius
    ) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { context in
            setFill()
            let rect = CGRect(origin: .zero, size: size)
            UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
            context.fill(rect)
        }.resizableImage(
            withCapInsets: .init(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)
        )
    }
}
