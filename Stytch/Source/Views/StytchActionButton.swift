//
//  StytchActionButton.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-17.
//

import UIKit

class StytchActionButton: UIButton {
    
    var customization: StytchUICustomization

    init(frame: CGRect = .zero, customization: StytchUICustomization) {
        self.customization = customization
        super.init(frame: frame)
        setupViews()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        layer.cornerRadius = customization.buttonCornerRadius
        backgroundColor = customization.buttonBackgroundColor
        setTitleColor(customization.buttonTextStyle.color, for: .normal)
        setTitleColor(UIColor(white: 0.5, alpha: 1.0), for: .highlighted)
        
        heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
        
        titleLabel?.font = customization.buttonTextStyle.font.withSize(StytchMagicLinkUI.shared.customization.buttonTextStyle.size)
    }
    
}
