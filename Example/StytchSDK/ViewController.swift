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
        StytchSDK.shared.start(from: self, delegate: self)
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController: StytchSDKDelegate {
    
    func onEvent(_ event: StytchEvent) {
        
    }
    
    func onSuccess(requstId: String, userId: String) {
        showAlert(title: "Success", message: "Request ID: \(requstId)\nUser ID: \(userId)")
    }
    
    func onFailure() {
        showAlert(title: "Failure", message: "SDK closed")
    }
    
    
}

