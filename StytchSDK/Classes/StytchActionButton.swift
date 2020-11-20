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
        
        layer.cornerRadius = 6
        backgroundColor = .black
        setTitleColor(.white, for: .normal)
        setTitleColor(UIColor(white: 0.5, alpha: 1.0), for: .highlighted)
        
        heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
        
        titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
