//
//  UIView+Constraints.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-17.
//

import UIKit

extension NSLayoutAnchor {
    @objc func constraintEqualToAnchor(anchor: NSLayoutAnchor!, constant:CGFloat, identifier:String) -> NSLayoutConstraint! {
        let constraint = self.constraint(equalTo: anchor, constant:constant)
        constraint.identifier = identifier
        return constraint
    }
    
    
}

extension NSLayoutDimension {
    
    @objc func constraintEqualToConstant(constant:CGFloat, identifier:String) -> NSLayoutConstraint! {
        let constraint = self.constraint(equalToConstant: constant)
        constraint.identifier = identifier
        return constraint
    }
}

extension UIView {
    
    func constraint(withIdentifier:String) -> NSLayoutConstraint? {
        return self.constraints.filter{ $0.identifier == withIdentifier }.first
    }
    
    func fillSuperview(padding: UIEdgeInsets) {
        anchor(top: superview?.topAnchor, left: superview?.leftAnchor, bottom: superview?.bottomAnchor, right: superview?.rightAnchor, padding: padding)
    }
    
    func fillSuperview() {
        fillSuperview(padding: .zero)
    }
    
    func constraintSize(_ size: CGSize) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }

    func anchor(top: NSLayoutYAxisAnchor?, left:NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        
        if let leading = left {
            leftAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        
        if let trailing = right {
            rightAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
}

