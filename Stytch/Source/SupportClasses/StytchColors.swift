//
//  StytchColors.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-12-01.
//

import UIKit

enum StytchColors: String {
    case TitleTextColor
    case SubtitleTextColor
    case InputTextColor
    case InputPlaceholderColor
    case InputBackgroundColor
    case InputBorderColor
    case ButtonTextColor
    case ButtonBackgroundColor
    case BackgroundColor
    
    var uiColor: UIColor {
        return UIColor(named: self.rawValue, in: Bundle(for: StytchUICustomization.self), compatibleWith: nil) ?? UIColor.black
    }
    
    var cgColor: CGColor {
        return uiColor.cgColor
    }
}

extension UIColor {
    
    var invertedWhiteBlack: UIColor {
        var alpha: CGFloat = 1.0
        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return ((red * 0.299 + green * 0.587 + blue * 0.114) * 255.0 > 140) ? .black : .white
        }
        return self
    }
}
