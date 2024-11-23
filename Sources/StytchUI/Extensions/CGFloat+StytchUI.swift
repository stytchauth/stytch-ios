import CoreGraphics

extension CGFloat {
    static var cornerRadius: CGFloat { StytchUIClient.configuration.theme.cornerRadius }
    static var verticalMargin: CGFloat { StytchUIClient.configuration.theme.verticalMargin }
    static var horizontalMargin: CGFloat { StytchUIClient.configuration.theme.horizontalMargin }
    static var buttonHeight: CGFloat { StytchUIClient.configuration.theme.buttonHeight }
    static var spacingTiny: CGFloat { StytchUIClient.configuration.theme.spacingTiny }
    static var spacingRegular: CGFloat { StytchUIClient.configuration.theme.spacingRegular }
    static var spacingLarge: CGFloat { StytchUIClient.configuration.theme.spacingLarge }
    static var spacingHuge: CGFloat { StytchUIClient.configuration.theme.spacingHuge }
}
