import Foundation
import UIKit

public extension UIFont {
    static func IBMPlexSansRegular(size: CGFloat) -> UIFont {
        UIFont(name: "IBMPlexSans-Regular", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }

    static func IBMPlexSansItalic(size: CGFloat) -> UIFont {
        UIFont(name: "IBMPlexSans-Italic", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }

    static func IBMPlexSansThin(size: CGFloat) -> UIFont {
        UIFont(name: "IBMPlexSans-Thin", size: size) ?? UIFont.systemFont(ofSize: size, weight: .thin)
    }

    static func IBMPlexSansThinItalic(size: CGFloat) -> UIFont {
        UIFont(name: "IBMPlexSans-ThinItalic", size: size) ?? UIFont.systemFont(ofSize: size, weight: .thin)
    }

    static func IBMPlexSansExtraLight(size: CGFloat) -> UIFont {
        UIFont(name: "IBMPlexSans-ExtraLight", size: size) ?? UIFont.systemFont(ofSize: size, weight: .ultraLight)
    }

    static func IBMPlexSansExtraLightItalic(size: CGFloat) -> UIFont {
        UIFont(name: "IBMPlexSans-ExtraLightItalic", size: size) ?? UIFont.systemFont(ofSize: size, weight: .ultraLight)
    }

    static func IBMPlexSansLight(size: CGFloat) -> UIFont {
        UIFont(name: "IBMPlexSans-Light", size: size) ?? UIFont.systemFont(ofSize: size, weight: .light)
    }

    static func IBMPlexSansLightItalic(size: CGFloat) -> UIFont {
        UIFont(name: "IBMPlexSans-LightItalic", size: size) ?? UIFont.systemFont(ofSize: size, weight: .light)
    }

    static func IBMPlexSansMedium(size: CGFloat) -> UIFont {
        UIFont(name: "IBMPlexSans-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }

    static func IBMPlexSansMediumItalic(size: CGFloat) -> UIFont {
        UIFont(name: "IBMPlexSans-MediumItalic", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }

    static func IBMPlexSansSemiBold(size: CGFloat) -> UIFont {
        UIFont(name: "IBMPlexSans-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
    }

    static func IBMPlexSansSemiBoldItalic(size: CGFloat) -> UIFont {
        UIFont(name: "IBMPlexSans-SemiBoldItalic", size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
    }

    static func IBMPlexSansBold(size: CGFloat) -> UIFont {
        UIFont(name: "IBMPlexSans-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }

    static func IBMPlexSansBoldItalic(size: CGFloat) -> UIFont {
        UIFont(name: "IBMPlexSans-BoldItalic", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }
}
