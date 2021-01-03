//
//  MagicLinkConfirmationViewController.swift
//  Stytch
//
//  Created by Ethan Furstoss on 12/22/20.
//

import UIKit
import WebKit

class MagicLinkConfirmationViewController: UIViewController {
    
    // MARK: Private Vars
    
    let email: String
    
    // MARK: UI Components

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StytchMagicLinkUI.shared.customization.titleStyle.font.withSize(StytchMagicLinkUI.shared.customization.titleStyle.size)
        label.numberOfLines = 0
        label.text = String(format: "stytch_login_waiting_verification_title".localized, email)
        label.textColor = StytchMagicLinkUI.shared.customization.titleStyle.color
        return label
    }()
    
    var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StytchMagicLinkUI.shared.customization.subtitleStyle.font.withSize(StytchMagicLinkUI.shared.customization.subtitleStyle.size)
        label.numberOfLines = 0
        label.text = "stytch_login_waiting_verification_description".localized
        label.textColor = StytchMagicLinkUI.shared.customization.subtitleStyle.color
        return label
    }()
    
    lazy var actionButton: StytchActionButton = {
        let button = StytchActionButton(customization: StytchMagicLinkUI.shared.customization)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("stytch_login_waiting_verification_button_title".localized, for: .normal)
        button.addTarget(self, action: #selector(handleActionButton), for: .touchUpInside)
        return button
    }()
    
    var poweredView: StytchPoweredView = {
        let view = StytchPoweredView(customization: StytchMagicLinkUI.shared.customization)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Parameters
    
    var buttonTopToSubtitileConstraint: NSLayoutConstraint!
    var buttonTopToTextFieldConstraint: NSLayoutConstraint!
    
    // MARK: Initializers
    
    init(email: String){
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = StytchMagicLinkUI.shared.customization.backgroundColor
        
        hideKeyboardWhenTappedAround()
        
        setupViews()
    }
    
    func setupViews() {
        
        var lastTopAnchor = view.safeAreaLayoutGuide.topAnchor
        var lastTopPadding: CGFloat = 32
        
        if StytchMagicLinkUI.shared.customization.showTitle {
            view.addSubview(titleLabel)
            titleLabel.anchor(top: lastTopAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, padding: .init(top: lastTopPadding, left: 24, bottom: 0, right: 24))
            
            lastTopAnchor = titleLabel.bottomAnchor
            lastTopPadding = 24
        }
        
        if StytchMagicLinkUI.shared.customization.showSubtitle {
            view.addSubview(subtitleLabel)
            subtitleLabel.anchor(top: lastTopAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, padding: .init(top: lastTopPadding, left: 24, bottom: 0, right: 24))
            
            lastTopAnchor = subtitleLabel.bottomAnchor
            lastTopPadding = 24
        }
        
        view.addSubview(actionButton)
        
        actionButton.anchor(top: lastTopAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, padding: .init(top: lastTopPadding, left: 24, bottom: 0, right: 24))
        
        if StytchMagicLinkUI.shared.customization.showBrandLogo {
            view.addSubview(poweredView)
            poweredView.anchor(top: actionButton.bottomAnchor, left: nil, bottom: nil, right: nil, padding: .init(top: 0, left: 24, bottom: 0, right: 24))
            poweredView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        }
        
    }
    
    // MARK: Actions
    
    @objc func handleActionButton() {
        self.navigationController?.popViewController(animated: true)
    }
}

