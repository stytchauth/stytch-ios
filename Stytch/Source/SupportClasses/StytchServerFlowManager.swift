//
//  StytchServerFlowManager.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-25.
//

import Foundation

class StytchServerFlowManager {
    
    var magicLinkResponse: MagicLinkModel?
    var userResponse: UserModel?
    
    var email: String = ""
    
    func sendMagicLink(to email: String, handler: @escaping (StytchError?)->() ) {
        
        let linkModel = PostMagicLinkModel()
        linkModel.email = email
        linkModel.magic_link_url = Stytch.shared.magicLink
        
        StytchApi.shared.sendMagicLink(model: linkModel) { (response) in
            if let model = response.data {
                self.magicLinkResponse = model
                self.email = email
                handler(nil)
            } else {
                
                if response.error.errorType == .emailNotFound {
                    if let _ = self.userResponse {
                        handler(self.convertError(type: response.error.errorType))
                    } else {
                        self.createUserAndSend(email: email, handler: handler)
                    }
                } else {
                    handler(self.convertError(type: response.error.errorType))
                }
            }
        }
    }
    
    private func createUserAndSend(email: String, handler: @escaping (StytchError?)->() ) {
        sendCreateUser(with: email) { createUserError in

            if let error = createUserError {
                handler(error)
            } else {
                
                self.sendMagicLink(to: email, handler: handler)
            }
        }
    }
    
    func sendCreateUser(with email: String, handler: @escaping (StytchError?)->() ) {
        
        let model = PostCreateUserModel()
        model.email = email
        
        StytchApi.shared.createUser(model: model) { (response) in
            if let model = response.data {
                self.userResponse = model
                handler(nil)
            } else {
                if response.error.errorType == .duplicateEmail {
                    handler(nil)
                } else {
                    handler(self.convertError(type: response.error.errorType))
                }
            }
        }
    }
    
    func authenticateMagicLink(with token: String, handler: @escaping (MagicLinkModel?, StytchError?)->()) {
        
        StytchApi.shared.authenticateMagicLink(token: token) { (response) in
            if let model = response.data {
                handler(model, nil)
            } else {
                handler(nil, self.convertError(type: response.error.errorType))
            }
        }
    }
    
    private func convertError(type: ErrorType) -> StytchError {
        switch type {
        case .unknown:
            return StytchError.connection
        case .emailNotFound:
            return StytchError.unknown // Should be handled when sending magic link
        case .duplicateEmail:
            return StytchError.unknown // Should be handled when creating user
        case .unableToAuthMagicLink:
            return StytchError.invalidMagicToken
        case .unauthorizedCredentials:
            return StytchError.invalidConfiguration
        case .internalServerError:
            return StytchError.unknown
        }
    }
}
