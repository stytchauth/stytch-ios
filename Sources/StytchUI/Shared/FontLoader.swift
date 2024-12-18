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
            "IBMPlexSans-Regular",
            "IBMPlexSans-Italic",
            "IBMPlexSans-Thin",
            "IBMPlexSans-ThinItalic",
            "IBMPlexSans-ExtraLight",
            "IBMPlexSans-ExtraLightItalic",
            "IBMPlexSans-Light",
            "IBMPlexSans-LightItalic",
            "IBMPlexSans-Medium",
            "IBMPlexSans-MediumItalic",
            "IBMPlexSans-SemiBold",
            "IBMPlexSans-SemiBoldItalic",
            "IBMPlexSans-Bold",
            "IBMPlexSans-BoldItalic",
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
