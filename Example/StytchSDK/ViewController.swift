//
//  ViewController.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 11/16/2020.
//

import UIKit
import StytchSDK

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
        
        StytchUI.shared.showUI(from: self, delegate: self)
    }
    
    func customizeStytch() {
        let customizaton = StytchUI.shared.customization
        
        customizaton.titleStyle.color = .red
        customizaton.titleStyle.size = 11
        
        customizaton.subtitleStyle.color = .cyan
        customizaton.subtitleStyle.size = 25
        customizaton.subtitleStyle.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        
        customizaton.inputTextStyle.color = .yellow
        customizaton.inputTextStyle.size = 13
        customizaton.inputTextStyle.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        customizaton.inputPlaceholderStyle.color = .orange
        customizaton.inputPlaceholderStyle.size = 21
        customizaton.inputPlaceholderStyle.font = UIFont.systemFont(ofSize: 12, weight: .light)
        
        customizaton.buttonTextStyle.color = .blue
        customizaton.buttonTextStyle.size = 9
        customizaton.buttonTextStyle.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        
        customizaton.buttonBackgroundColor = .systemPink
        customizaton.buttonCornerRadius = 24
        
        customizaton.backgroundColor = .green
        customizaton.inputBackgroundColor = .magenta
        
        customizaton.showTitle = false
        customizaton.showSubtitle = false
        customizaton.showBrandLogo = false
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController: StytchUIDelegate {
    
    func onEvent(_ event: StytchEvent) {
        print("Event Type: \(event.type)")
        print("Is user created: \(event.created)")
        print("User ID: \(event.userId)")
    }
    
    func onSuccess(_ result: StytchResult) {
        showAlert(title: "Success", message: "Request ID: \(result.requestId)\nUser ID: \(result.userId)")
    }
    
    func onFailure() {
        showAlert(title: "Failure", message: "SDK closed")
    }
    
    
}

