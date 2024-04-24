import UIKit

/// A class defining a color pair, used for displaying the Stytch UI in both light and dark modes. Initialize a color pair with your own `dark` and `light` colors and pass them to the `StytchTheme` to use.
public class UIColorPair: Codable {
    enum CodingKeys: String, CodingKey {
        case dark
        case light
    }

    let dark: UIColor
    let light: UIColor

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let darkData = try container.decode(Data.self, forKey: .dark)
        let lightData = try container.decode(Data.self, forKey: .light)

        guard let darkColor = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [UIColor.self], from: darkData) as? UIColor, let lightColor = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [UIColor.self], from: lightData) as? UIColor
        else {
            throw DecodingError.dataCorruptedError(forKey: .dark, in: container, debugDescription: "Invalid color data")
        }

        dark = darkColor
        light = lightColor
    }

    public init(dark: UIColor, light: UIColor) {
        self.dark = dark
        self.light = light
    }

    public func get(style: UIUserInterfaceStyle) -> UIColor {
        if style == .dark {
            return dark
        } else {
            return light
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        guard let darkData = try? NSKeyedArchiver.archivedData(withRootObject: dark, requiringSecureCoding: false), let lightData = try? NSKeyedArchiver.archivedData(withRootObject: light, requiringSecureCoding: false)
        else {
            throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: container.codingPath, debugDescription: "Invalid color data"))
        }

        try container.encode(darkData, forKey: .dark)
        try container.encode(lightData, forKey: .light)
    }
}

/// A class defining the theme of your UI. If no custom properties are supplied, it will default to the default Stytch theme
public class StytchTheme: Codable {
    /// The `UIColorPair` describing the background color
    let background: UIColorPair
    /// The `UIColorPair` describing the primary text color
    let primaryText: UIColorPair
    /// The `UIColorPair` describing the placeholder test color
    let placeholderText: UIColorPair
    /// The `UIColorPair` describing the disabled text color
    let disabledText: UIColorPair
    /// The `UIColorPair` describing the secondary text color
    let secondaryText: UIColorPair
    /// The `UIColorPair` describing the danger test color
    let dangerText: UIColorPair
    /// The `UIColorPair` describing the active border color
    let borderActive: UIColorPair
    /// The `UIColorPair` describing the primary button background color
    let primaryButton: UIColorPair
    /// The `UIColorPair` describing the primary button text color
    let primaryButtonText: UIColorPair
    /// The `UIColorPair` describing the primary button disabled background color
    let primaryButtonDisabled: UIColorPair
    /// The `UIColorPair` describing the primary button disabled text color
    let primaryButtonTextDisabled: UIColorPair
    /// The `UIColorPair` describing the secondary button background color
    let secondaryButton: UIColorPair
    /// The `UIColorPair` describing the secondary button text color
    let secondaryButtonText: UIColorPair
    /// The `UIColorPair` describing the tertiary button background color
    let tertiaryButton: UIColorPair
    /// The `UIColorPair` describing the disabled textfield background color
    let textfieldDisabled: UIColorPair
    /// The `UIColorPair` describing the disabled textfield border color
    let textfieldDisabledBorder: UIColorPair
    /// The `UIColorPair` describing the default background color of the ZXCVBN password strength indicator bar
    let progressDefault: UIColorPair
    /// The `UIColorPair` describing the successful background color of the ZXCVBN password strength indicator bar
    let progressSuccess: UIColorPair
    /// The `UIColorPair` describing the error background color of the ZXCVBN password strength indicator bar
    let progressDanger: UIColorPair
    /// A `CGFloat` describing the radius of corners where applied. Defaults to 4
    let cornerRadius: CGFloat
    /// A `CGFloat` describing the vertical margins where applied. Defaults to 64
    let verticalMargin: CGFloat
    /// A `CGFloat` describing the horizontal margins where applied. Defaults to 32
    let horizontalMargin: CGFloat
    /// A `CGFloat` describing the height of buttons. Defaults to 45
    let buttonHeight: CGFloat
    /// A `CGFloat` describing the tiny spacing unit. Defaults to 4
    let spacingTiny: CGFloat
    /// A `CGFloat` describing the regular spacing unit. Defaults to 12
    let spacingRegular: CGFloat
    /// A `CGFloat` describing the large spacing unit. Defaults to 24
    let spacingLarge: CGFloat
    /// A `CGFloat` describing the huge spacing unit. Defaults to 32
    let spacingHuge: CGFloat

    public init(
        background: UIColorPair = .init(dark: .charcoal, light: .white),
        primaryText: UIColorPair = .init(dark: .chalk, light: .black),
        placeholderText: UIColorPair = .init(dark: .steel, light: .steel),
        disabledText: UIColorPair = .init(dark: .steel, light: .steel),
        secondaryText: UIColorPair = .init(dark: .cement, light: .slate),
        dangerText: UIColorPair = .init(dark: .peach, light: .maroon),
        borderActive: UIColorPair = .init(dark: .slate, light: .cement),
        primaryButton: UIColorPair = .init(dark: .white, light: .charcoal),
        primaryButtonText: UIColorPair = .init(dark: .charcoal, light: .white),
        primaryButtonDisabled: UIColorPair = .init(dark: .ink, light: .chalk),
        primaryButtonTextDisabled: UIColorPair = .init(dark: .steel, light: .steel),
        secondaryButton: UIColorPair = .init(dark: .charcoal, light: .white),
        secondaryButtonText: UIColorPair = .init(dark: .white, light: .charcoal),
        tertiaryButton: UIColorPair = .init(dark: .white, light: .charcoal),
        textfieldDisabled: UIColorPair = .init(dark: .ink, light: .chalk),
        textfieldDisabledBorder: UIColorPair = .init(dark: .ink, light: .fog),
        progressDefault: UIColorPair = .init(dark: .cement, light: .cement),
        progressSuccess: UIColorPair = .init(dark: .mint, light: .pine),
        progressDanger: UIColorPair = .init(dark: .peach, light: .maroon),
        cornerRadius: CGFloat = 4,
        verticalMargin: CGFloat = 64,
        horizontalMargin: CGFloat = 32,
        buttonHeight: CGFloat = 45,
        spacingTiny: CGFloat = 4,
        spacingRegular: CGFloat = 12,
        spacingLarge: CGFloat = 24,
        spacingHuge: CGFloat = 32
    ) {
        self.background = background
        self.primaryText = primaryText
        self.placeholderText = placeholderText
        self.disabledText = disabledText
        self.secondaryText = secondaryText
        self.dangerText = dangerText
        self.borderActive = borderActive
        self.primaryButton = primaryButton
        self.primaryButtonText = primaryButtonText
        self.primaryButtonDisabled = primaryButtonDisabled
        self.primaryButtonTextDisabled = primaryButtonTextDisabled
        self.secondaryButton = secondaryButton
        self.secondaryButtonText = secondaryButtonText
        self.tertiaryButton = tertiaryButton
        self.textfieldDisabled = textfieldDisabled
        self.textfieldDisabledBorder = textfieldDisabledBorder
        self.progressDefault = progressDefault
        self.progressSuccess = progressSuccess
        self.progressDanger = progressDanger
        self.cornerRadius = cornerRadius
        self.verticalMargin = verticalMargin
        self.horizontalMargin = horizontalMargin
        self.buttonHeight = buttonHeight
        self.spacingTiny = spacingTiny
        self.spacingRegular = spacingRegular
        self.spacingLarge = spacingLarge
        self.spacingHuge = spacingHuge
    }
}
