import UIKit

public extension UIColor {
    // #19303D greyscale, dark.text.contrast
    static let charcoal: UIColor = .black // .init(red: 0.10, green: 0.19, blue: 0.24, alpha: 1.00)
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
    static let background: UIColor = .init { StytchUIClient.configuration.theme.background.get(style: $0.userInterfaceStyle) }

    static let primaryText: UIColor = .init { StytchUIClient.configuration.theme.primaryText.get(style: $0.userInterfaceStyle) }
    static let placeholderText: UIColor = .init { StytchUIClient.configuration.theme.placeholderText.get(style: $0.userInterfaceStyle) }
    static let disabledText: UIColor = .init { StytchUIClient.configuration.theme.disabledText.get(style: $0.userInterfaceStyle) }
    static let secondaryText: UIColor = .init { StytchUIClient.configuration.theme.secondaryText.get(style: $0.userInterfaceStyle) }
    static let dangerText: UIColor = .init { StytchUIClient.configuration.theme.dangerText.get(style: $0.userInterfaceStyle) }

    static let borderActive: UIColor = .init { StytchUIClient.configuration.theme.borderActive.get(style: $0.userInterfaceStyle) }

    static let primaryButton: UIColor = .init { StytchUIClient.configuration.theme.primaryButton.get(style: $0.userInterfaceStyle) }
    static let primaryButtonText: UIColor = .init { StytchUIClient.configuration.theme.primaryButtonText.get(style: $0.userInterfaceStyle) }
    static let primaryButtonDisabled: UIColor = .init { StytchUIClient.configuration.theme.primaryButtonDisabled.get(style: $0.userInterfaceStyle) }
    static let primaryButtonTextDisabled: UIColor = .init { StytchUIClient.configuration.theme.primaryButtonTextDisabled.get(style: $0.userInterfaceStyle) }

    static let secondaryButton: UIColor = .init { StytchUIClient.configuration.theme.secondaryButton.get(style: $0.userInterfaceStyle) }
    static let secondaryButtonText: UIColor = .init { StytchUIClient.configuration.theme.secondaryButtonText.get(style: $0.userInterfaceStyle) }

    static let tertiaryButton: UIColor = .init { StytchUIClient.configuration.theme.tertiaryButton.get(style: $0.userInterfaceStyle) }

    static let textfieldDisabled: UIColor = .init { StytchUIClient.configuration.theme.textfieldDisabled.get(style: $0.userInterfaceStyle) }
    static let textfieldDisabledBorder: UIColor = .init { StytchUIClient.configuration.theme.textfieldDisabledBorder.get(style: $0.userInterfaceStyle) }

    static let progressDefault: UIColor = .init { StytchUIClient.configuration.theme.progressDefault.get(style: $0.userInterfaceStyle) }
    static let progressSuccess: UIColor = .init { StytchUIClient.configuration.theme.progressSuccess.get(style: $0.userInterfaceStyle) }
    static let progressDanger: UIColor = .init { StytchUIClient.configuration.theme.progressDanger.get(style: $0.userInterfaceStyle) }
}

extension UIColor {
    func image(
        size: CGSize? = nil,
        cornerRadius: CGFloat? = nil
    ) -> UIImage {
        let cornerRadius: CGFloat = cornerRadius ?? .cornerRadius
        let size: CGSize = size ?? CGSize(width: 2 * cornerRadius, height: 2 * cornerRadius)
        return UIGraphicsImageRenderer(size: size)
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
