import CoreText
import UIKit

// swiftlint:disable indentation_width legacy_objc_type opening_brace
public enum FontLoader {
    static var fontsLoaded = false

    static func loadFonts() {
        guard fontsLoaded == false else {
            return
        }

        let fonts = [
            "IBMPlexSans-Bold",
            "IBMPlexSans-BoldItalic",
            "IBMPlexSans-ExtraLight",
            "IBMPlexSans-ExtraLightItalic",
            "IBMPlexSans-Italic",
            "IBMPlexSans-Light",
            "IBMPlexSans-LightItalic",
            "IBMPlexSans-Medium",
            "IBMPlexSans-MediumItalic",
            "IBMPlexSans-MediumItalic",
            "IBMPlexSans-SemiBold",
            "IBMPlexSans-SemiBoldItalic",
            "IBMPlexSans-Thin",
            "IBMPlexSans-ThinItalic",
        ]

        for fontName in fonts {
            if let asset = NSDataAsset(name: "Fonts/\(fontName)", bundle: Bundle.module),
               let provider = CGDataProvider(data: asset.data as NSData),
               let font = CGFont(provider)
            {
                CTFontManagerRegisterGraphicsFont(font, nil)
            } else {
                print("failed to register font: \(fontName)")
            }
        }

        fontsLoaded = true
    }
}
