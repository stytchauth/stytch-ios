//
//  StytchActionButton.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-17.
//

import UIKit

class StytchActionButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = StytchUI.shared.customization.buttonCornerRadius
        backgroundColor = StytchUI.shared.customization.buttonBackgroundColor
        setTitleColor(StytchUI.shared.customization.buttonTextStyle.color, for: .normal)
        setTitleColor(UIColor(white: 0.5, alpha: 1.0), for: .highlighted)
        
        heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
        
        titleLabel?.font = StytchUI.shared.customization.buttonTextStyle.font.withSize(StytchUI.shared.customization.buttonTextStyle.size)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
