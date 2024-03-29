import UIKit

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

public class StytchTheme: Codable {
    let background: UIColorPair
    let primaryText: UIColorPair
    let placeholderText: UIColorPair
    let disabledText: UIColorPair
    let secondaryText: UIColorPair
    let dangerText: UIColorPair
    let borderActive: UIColorPair
    let primaryButton: UIColorPair
    let primaryButtonText: UIColorPair
    let primaryButtonDisabled: UIColorPair
    let primaryButtonTextDisabled: UIColorPair
    let secondaryButton: UIColorPair
    let secondaryButtonText: UIColorPair
    let tertiaryButton: UIColorPair
    let textfieldDisabled: UIColorPair
    let textfieldDisabledBorder: UIColorPair
    let progressDefault: UIColorPair
    let progressSuccess: UIColorPair
    let progressDanger: UIColorPair
    let cornerRadius: CGFloat
    let verticalMargin: CGFloat
    let horizontalMargin: CGFloat
    let buttonHeight: CGFloat
    let spacingTiny: CGFloat
    let spacingRegular: CGFloat
    let spacingLarge: CGFloat
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
