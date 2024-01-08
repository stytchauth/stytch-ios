import CoreGraphics

extension CGFloat {
    static var cornerRadius: CGFloat { get { StytchUIClient.config!.theme.cornerRadius } }
    static var verticalMargin: CGFloat { get { StytchUIClient.config!.theme.verticalMargin } }
    static var horizontalMargin: CGFloat { get { StytchUIClient.config!.theme.horizontalMargin } }
    static var buttonHeight: CGFloat { get { StytchUIClient.config!.theme.buttonHeight } }
    static var spacingTiny: CGFloat { get { StytchUIClient.config!.theme.spacingTiny } }
    static var spacingRegular: CGFloat { get { StytchUIClient.config!.theme.spacingRegular } }
    static var spacingLarge: CGFloat { get { StytchUIClient.config!.theme.spacingLarge } }
    static var spacingHuge: CGFloat { get { StytchUIClient.config!.theme.spacingHuge } }
}
