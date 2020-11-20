//
//  StytchModelViewController.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-20.
//

import Foundation

enum StytchAuthState {
    case login
    case waitingEmailVerification(String)
    case waitingMagicLink(String)
}

protocol StytchModelViewControllerDelegate {
    func errorOccured(_ error: String)
    func apply(state: StytchAuthState)
    func authenticateMagicLink()
    func authenticationSuccessful(model: MagicLinkModel)
}

class StytchModelViewController {
    
    static let shared = StytchModelViewController()
    private init() {}
    
    var magicLinkResponse: MagicLinkModel?
    var userResponse: UserModel?
    
    var state: StytchAuthState = .login
    
    var delegate: StytchModelViewControllerDelegate?
    
    func reset() {
        magicLinkResponse = nil
        userResponse = nil
        state = .login
        StytchModelViewController.shared.delegate?.apply(state: .login)
    }
    
    func performStep(inputValue: String) {
        switch state {
        case .login:
            if !inputValue.isValidEmail {
                StytchModelViewController.shared.delegate?.errorOccured("Wrong email format")
                return
            }
            #warning("Check for need to send email verification")
            
            StytchModelViewController.shared.sendMagicLink(to: inputValue)
            
        case .waitingEmailVerification(_):
            // Resend email verification
            break
            
        case .waitingMagicLink(let email):
            StytchModelViewController.shared.sendMagicLink(to: email)
        }
    }
    
    func authenticateMagcLink(with token: String) {
        StytchModelViewController.shared.delegate?.authenticateMagicLink()
        
        StytchApi.shared.authenticateMagicLink(token: token) { (response) in
            if let model = response.data {
                StytchModelViewController.shared.delegate?.authenticationSuccessful(model: model)
            } else {
                print("Error type:", response.error.errorType.message)
                StytchModelViewController.shared.delegate?.errorOccured(response.error.errorType.message)
            }
        }
    }
    
    private func sendMagicLink(to email: String) {
        
        let linkModel = PostMagicLinkModel()
        linkModel.email = email
        linkModel.magic_link_url = StytchSDK.shared.magicLink
        
        StytchApi.shared.sendMagicLink(model: linkModel) { (response) in
            if let model = response.data {
                StytchModelViewController.shared.magicLinkResponse = model
                StytchModelViewController.shared.delegate?.apply(state: .waitingMagicLink(email))
            } else {
                print("Error:", response.error.errorType.message)
                if response.error.errorType == .emailNotFound {
                    self.sendCreateUser(with: email)
                } else {
                    StytchModelViewController.shared.delegate?.errorOccured(response.error.errorType.message)
                }
            }
        }
    }
    
    private func sendCreateUser(with email: String) {
        
        let model = PostCreateUserModel()
        model.email = email
        
        StytchApi.shared.createUser(model: model) { (response) in
            if let model = response.data {
                StytchModelViewController.shared.userResponse = model
                StytchModelViewController.shared.sendMagicLink(to: email)
                
            } else {
                print("Error type:", response.error.errorType.message)
                StytchModelViewController.shared.delegate?.errorOccured(response.error.errorType.message)
            }
        }
    }
    
}
