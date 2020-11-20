//
//  StytchAuthViewController.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-17.
//

import UIKit
import WebKit

class StytchAuthViewController: UIViewController {
    
    // MARK: UI Components
    
    var wkWebView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let wkWebView = WKWebView(frame: .zero, configuration: webConfiguration)
        return wkWebView
    }()

    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        label.numberOfLines = 0
        label.text = "Sign up or log in"
        label.textColor = .black
        return label
    }()
    
    var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.text = "Sign up or log in with your email, no password needed."
        label.textColor = .black
        return label
    }()
    
    var textField: StytchTextField = {
        let textField = StytchTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholderText = "example@email.com"
//        textField.text = "edgar@logicants.com"
        return textField
    }()
    
    lazy var actionButton: StytchActionButton = {
        let button = StytchActionButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign in with Email", for: .normal)
        button.addTarget(self, action: #selector(handleActionButton), for: .touchUpInside)
        return button
    }()
    
    var poweredView: StytchPoweredView = {
        let view = StytchPoweredView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = .black
        view.isHidden = true
        return view
    }()
    
    // MARK: Parameters
    
    var buttonTopToSubtitileConstraint: NSLayoutConstraint!
    var buttonTopToTextFieldConstraint: NSLayoutConstraint!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        hideKeyboardWhenTappedAround()
        
        StytchModelViewController.shared.delegate = self
        
        setupViews()
        
        getUserAgent { (agent) in
            AttributesModel.preloadedAgent = agent
        }
    }
    
    func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(textField)
        view.addSubview(actionButton)
        view.addSubview(poweredView)
        view.addSubview(activityIndicatorView)
        
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, padding: .init(top: 32, left: 24, bottom: 0, right: 24))
        
        subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, padding: .init(top: 24, left: 24, bottom: 0, right: 24))
        
        textField.anchor(top: subtitleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, padding: .init(top: 24, left: 24, bottom: 0, right: 24))
        
        actionButton.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, padding: .init(top: 0, left: 24, bottom: 0, right: 24))
        
        buttonTopToSubtitileConstraint = actionButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24)
        buttonTopToTextFieldConstraint = actionButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24)
        buttonTopToTextFieldConstraint.isActive = true
        
        poweredView.anchor(top: actionButton.bottomAnchor, left: nil, bottom: nil, right: nil, padding: .init(top: 0, left: 24, bottom: 0, right: 24))
        poweredView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func getUserAgent(handler: @escaping (String?)->()){
        wkWebView.evaluateJavaScript("navigator.userAgent", completionHandler: { (result, error) in
            handler(result as? String)
        })
    }
    
    // MARK: Actions
        
    @objc func handleActionButton() {
        showLoading()
        StytchModelViewController.shared.performStep(inputValue: self.textField.text)
    }
    
    func showLoading() {
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
    }
    
    func hideLoading() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

extension StytchAuthViewController: StytchModelViewControllerDelegate {
    
    func errorOccured(_ error: String) {
        hideLoading()
        showAlert(title: "Error!", message: error)
    }
    
    func apply(state: StytchAuthState) {
        defer {
            hideLoading()
        }
        
        var buttonText = ""
        var titleText = ""
        var subtitleText = ""
        
        var showInputField = true
        
        switch state {
        case .login:
            buttonText = "Sign in with Email"
            titleText = "Sign up or log in"
            subtitleText = "Sign up or log in with your email, no password needed."
            showInputField = true
            
        case .waitingEmailVerification(let email):
            buttonText = "Resend email"
            titleText = "Email sent to \(email)"
            subtitleText = "Didn’t get email? Check your spam folder, or"
            showInputField = false
            
        case .waitingMagicLink(let email):
            buttonText = "Resend magic link"
            titleText = "Email sent to \(email)"
            subtitleText = "Didn’t get email? Check your spam folder, or"
            showInputField = false
        }
        
        UIView.transition(with: titleLabel, duration: 0.3, options: .curveEaseIn) {
            self.titleLabel.alpha = 0
            self.titleLabel.text = titleText
            self.titleLabel.alpha = 1
        } completion: { (_) in
            
        }
        
        UIView.transition(with: subtitleLabel, duration: 0.3, options: .curveEaseIn) {
            self.subtitleLabel.alpha = 0
            self.subtitleLabel.text = subtitleText
            self.subtitleLabel.alpha = 1
        } completion: { (_) in
            
        }
        
        if showInputField {
            
            if self.textField.alpha < 1 {
                
                self.textField.isHidden = false
                self.buttonTopToSubtitileConstraint.isActive = false
                self.buttonTopToTextFieldConstraint.isActive = true
                
                UIView.animate(withDuration: 0.3) {
                    self.textField.alpha = 1
                    self.view.layoutIfNeeded()
                }

            }
            
        } else {
            
            if self.textField.alpha > 0 {
                
                self.buttonTopToTextFieldConstraint.isActive = false
                self.buttonTopToSubtitileConstraint.isActive = true
                
                UIView.animate(withDuration: 0.3) {
                    self.textField.alpha = 1
                    self.view.layoutIfNeeded()
                } completion: { (finished) in
                    if finished {
                        self.textField.isHidden = true
                    }
                }


            }
        }
        
        actionButton.setTitle(buttonText, for: .normal)
    }
    
    func authenticateMagicLink() {
        showLoading()
    }
    
    func authenticationSuccessful(model: MagicLinkModel) {
        dismiss(animated: true) {
            StytchSDK.shared.delegate?.onSuccess(requstId: model.requestId, userId: model.userId)
        }
    }
    
    
}
