//
//  StytchPoweredView.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-17.
//

import UIKit

class StytchPoweredView: UIView {
    
    var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 1
        label.text = "Powered by"
        label.textColor = UIColor(red: 146.0/255.0, green: 142.0/255.0, blue: 142.0/255.0, alpha: 1.0)
        return label
    }()
    
    var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        let bundle = Bundle(for: StytchAuthViewController.self)
        imageView.image = UIImage(named: "stytch_logo", in: bundle, compatibleWith: nil)
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(subtitleLabel)
        addSubview(logoImageView)
        
        subtitleLabel.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil)
        subtitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        logoImageView.anchor(top: topAnchor, left: subtitleLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor, padding: .init(top: 0, left: 8, bottom: 0, right: 0), size: .init(width: 56, height: 56))
    }
}
