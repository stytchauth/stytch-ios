import UIKit

private extension UIColor {
    // #19303D greyscale, dark.text.contrast
    static let charcoal: UIColor = .init(red: 0.10, green: 0.19, blue: 0.24, alpha: 1.00)
    // #8296A1 dark.text.disabled, light.text.disabled
    static let steel: UIColor = .init(red: 0.51, green: 0.59, blue: 0.63, alpha: 1.00)
    // #5C727D greyscale, light.text.secondary, dark.border.active
    static let slate: UIColor = .init(red: 0.36, green: 0.45, blue: 0.49, alpha: 1.00)
    // #354D5A greyscale, dark.border.subtle
    static let ink: UIColor = .init(red: 0.21, green: 0.30, blue: 0.35, alpha: 1.00)
    // #ADBCC5 dark.text.secondary, light.border.active
    static let cement: UIColor = .init(red: 0.68, green: 0.74, blue: 0.77, alpha: 1.00)
    // #F3F5F6 dark.text.primary
    static let chalk: UIColor = .init(red: 0.95, green: 0.96, blue: 0.96, alpha: 1.00)
    // #FFD4CD dark.text.danger
    static let peach: UIColor = .init(red: 1.00, green: 0.83, blue: 0.80, alpha: 1.00)
    // #C6FFE0 dark.text.success
    static let mint: UIColor = .init(red: 0.78, green: 1.00, blue: 0.88, alpha: 1.00)
    // #8B1214 light.border.danger
    static let maroon: UIColor = .init(red: 0.55, green: 0.07, blue: 0.08, alpha: 1.00)
    // #0C5A56 light.text.success
    static let pine: UIColor = .init(red: 0.05, green: 0.35, blue: 0.34, alpha: 1.00)
    // #E5E8EB light.border.subtle
    static let fog: UIColor = .init(red: 0.90, green: 0.91, blue: 0.92, alpha: 1.00)
}

extension UIColor {
    static let background: UIColor = .init { $0.userInterfaceStyle == .dark ? .charcoal : .white }

    static let primaryText: UIColor = .init { $0.userInterfaceStyle == .dark ? .chalk : .black }
    static let placeholderText: UIColor = .init { $0.userInterfaceStyle == .dark ? .steel : .steel }
    static let disabledText: UIColor = .init { $0.userInterfaceStyle == .dark ? .steel : .steel }
    static let secondaryText: UIColor = .init { $0.userInterfaceStyle == .dark ? .cement : .slate }
    static let dangerText: UIColor = .init { $0.userInterfaceStyle == .dark ? .peach : .maroon }

    static let borderActive: UIColor = .init { $0.userInterfaceStyle == .dark ? .slate : .cement }

    static let primaryButton: UIColor = .init { $0.userInterfaceStyle == .dark ? .white : .charcoal }
    static let primaryButtonText: UIColor = .init { $0.userInterfaceStyle == .dark ? .charcoal : .white }
    static let primaryButtonDisabled: UIColor = .init { $0.userInterfaceStyle == .dark ? .ink : .chalk }
    static let primaryButtonTextDisabled: UIColor = .init { $0.userInterfaceStyle == .dark ? .steel : .steel }

    static let secondaryButton: UIColor = .init { $0.userInterfaceStyle == .dark ? .charcoal : .white }
    static let secondaryButtonText: UIColor = .init { $0.userInterfaceStyle == .dark ? .white : .charcoal }

    static let tertiaryButton: UIColor = .init { $0.userInterfaceStyle == .dark ? .white : .charcoal }

    static let textfieldDisabled: UIColor = .init { $0.userInterfaceStyle == .dark ? .ink : .chalk }
    static let textfieldDisabledBorder: UIColor = .init { $0.userInterfaceStyle == .dark ? .ink : .fog }

    static let progressDefault: UIColor = .init { $0.userInterfaceStyle == .dark ? .cement : .cement }
    static let progressSuccess: UIColor = .init { $0.userInterfaceStyle == .dark ? .mint : .pine }
    static let progressDanger: UIColor = .init { $0.userInterfaceStyle == .dark ? .peach : .maroon }
}

extension UIColor {
    func image(
        size: CGSize = CGSize(width: 2 * .cornerRadius, height: 2 * .cornerRadius),
        cornerRadius: CGFloat = .cornerRadius
    ) -> UIImage {
        UIGraphicsImageRenderer(size: size)
            .image { context in
                setFill()
                let rect = CGRect(origin: .zero, size: size)
                UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
                context.fill(rect)
            }
            .resizableImage(
                withCapInsets: .init(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)
            )
    }
}
