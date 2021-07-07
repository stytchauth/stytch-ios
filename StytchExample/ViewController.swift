//
//  ViewController.swift
//  StytchExample
//
//  Created by Edgar Kroman on 2020-12-04.
//

import UIKit
import Stytch

class ViewController: UIViewController {
    
    lazy var startSDKButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Start STYTCH SDK", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        button.addTarget(self, action: #selector(handleStartSDK), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(startSDKButton)
        
        startSDKButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        startSDKButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        startSDKButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24).isActive = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleStartSDK() {
//        customizeStytch()
        
        Stytch.shared.environment = .test
 //       StytchMagicLinkUI.shared.showUI(from: self)
    }
    
    func customizeStytch() {
        let customizaton = StytchMagicLinkUI.shared.customization
        
        let textColor = UIColor(red: 110.0/255.0, green: 71.0/255.0, blue: 31.0/255.0, alpha: 1.0)
        let placeholderTextColor = UIColor(red: 138.0/255.0, green: 90.0/255.0, blue: 40.0/255.0, alpha: 1.0)
        let inputBackgroundColor = UIColor(red: 232.0/255.0, green: 189.0/255.0, blue: 144.0/255.0, alpha: 1.0)
        let backgroundColor = UIColor(red: 245.0/255.0, green: 212.0/255.0, blue: 176.0/255.0, alpha: 1.0)
        
        customizaton.titleStyle.color = textColor
        customizaton.titleStyle.size = 25
        customizaton.titleStyle.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        
        customizaton.subtitleStyle.color = textColor
        customizaton.subtitleStyle.size = 18
        customizaton.subtitleStyle.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        customizaton.inputTextStyle.color = textColor
        customizaton.inputTextStyle.size = 16
        customizaton.inputTextStyle.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        customizaton.inputPlaceholderStyle.color = placeholderTextColor
        customizaton.inputPlaceholderStyle.size = 15
        customizaton.inputPlaceholderStyle.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        customizaton.inputBackgroundColor = inputBackgroundColor
        customizaton.inputBorderColor = textColor
        customizaton.inputCornerRadius = 8
        
        customizaton.buttonTextStyle.color = .white
        customizaton.buttonTextStyle.size = 20
        customizaton.buttonTextStyle.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        
        customizaton.buttonBackgroundColor = textColor
        customizaton.buttonCornerRadius = 8
        
        customizaton.backgroundColor = backgroundColor
        
        customizaton.showTitle = true
        customizaton.showSubtitle = true
        customizaton.showBrandLogo = true
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

