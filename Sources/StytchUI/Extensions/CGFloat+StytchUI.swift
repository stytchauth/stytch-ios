import CoreGraphics

extension CGFloat {
    static var cornerRadius: CGFloat { StytchUIClient.config.theme.cornerRadius }
    static var verticalMargin: CGFloat { StytchUIClient.config.theme.verticalMargin }
    static var horizontalMargin: CGFloat { StytchUIClient.config.theme.horizontalMargin }
    static var buttonHeight: CGFloat { StytchUIClient.config.theme.buttonHeight }
    static var spacingTiny: CGFloat { StytchUIClient.config.theme.spacingTiny }
    static var spacingRegular: CGFloat { StytchUIClient.config.theme.spacingRegular }
    static var spacingLarge: CGFloat { StytchUIClient.config.theme.spacingLarge }
    static var spacingHuge: CGFloat { StytchUIClient.config.theme.spacingHuge }
}
