//
//  StytchCustomization.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-24.
//

import UIKit

@objc(StytchUICustomization) public class StytchUICustomization: NSObject {
    
    @objc public let titleStyle: StytchTextStyle = StytchTextStyle(font: UIFont.systemFont(ofSize: 30, weight: .medium),
                                                                       size: 30,
                                                                       color: .black)
    
    @objc public var showTitle: Bool = true
    
    @objc public let subtitleStyle: StytchTextStyle = StytchTextStyle(font: UIFont.systemFont(ofSize: 16, weight: .regular),
                                                                       size: 16,
                                                                       color: .black)
    
    @objc public var showSubtitle: Bool = true
    
    @objc public let inputTextStyle: StytchTextStyle = StytchTextStyle(font: UIFont.systemFont(ofSize: 16, weight: .regular),
                                                                       size: 16,
                                                                       color: .black)
    
    @objc public let inputPlaceholderStyle: StytchTextStyle = StytchTextStyle(font: UIFont.systemFont(ofSize: 16, weight: .regular),
                                                                       size: 16,
                                                                       color: UIColor(red: 146.0/255.0, green: 142.0/255.0, blue: 142.0/255.0, alpha: 1.0))
    
    @objc public var inputBackgroundColor: UIColor = .white
    
    @objc public var inputBorderColor: UIColor =  UIColor.black.withAlphaComponent(0.22)
    
    @objc public var inputCornerRadius: CGFloat = 5
    
    @objc public let buttonTextStyle: StytchTextStyle = StytchTextStyle(font: UIFont.systemFont(ofSize: 18, weight: .medium),
                                                                       size: 18,
                                                                       color: .white)
    
    @objc public var buttonBackgroundColor: UIColor = .black
    
    @objc public var buttonCornerRadius: CGFloat = 5
    
    @objc public var showBrandLogo: Bool = true
    
    @objc public var backgroundColor: UIColor = .white
    
}

@objc(StytchTextStyle) public class StytchTextStyle: NSObject {
    
    @objc public var font: UIFont
    @objc public var size: CGFloat
    @objc public var color: UIColor
    
    init(font: UIFont, size: CGFloat, color: UIColor) {
        self.font = font
        self.size = size
        self.color = color
        super.init()
    }
    
}
