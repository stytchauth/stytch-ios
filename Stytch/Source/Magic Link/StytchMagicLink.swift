//
//  Stytch.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-24.
//

import UIKit

@objc(Stytch) public class StytchMagicLink: NSObject {
    
    @objc public static let shared: StytchMagicLink = StytchMagicLink()
    
    private override init() {}
    
    var MAGIC_SCHEME = ""
    var MAGIC_HOST = ""
    
    var serverManager = StytchMagicLinkServerFlowManager()
    
    var DEBUG: Bool = false
    
    var loginMagicLink: String {
        return "\(MAGIC_SCHEME)://\(MAGIC_HOST)\(StytchConstants.LOGIN_MAGIC_PATH)"
    }
    
    var signUpMagicLink: String {
        return "\(MAGIC_SCHEME)://\(MAGIC_HOST)\(StytchConstants.SIGNUP_MAGIC_PATH)"
    }
    
    var inviteMagicLink: String {
        return "\(MAGIC_SCHEME)://\(MAGIC_HOST)\(StytchConstants.INVITE_MAGIC_PATH)"
    }
    
    func clearData() {
        serverManager = StytchMagicLinkServerFlowManager()
        delegate = nil
    }
    
    @objc public var environment: StytchEnvironment = .live
    @objc public var loginMethod: StytchLoginMethod = .loginOrSignUp

    @objc public var delegate: StytchMagicLinkDelegate?

    @objc public func configure(projectID: String, secret: String, scheme: String, host: String) {
        self.MAGIC_SCHEME = scheme
        self.MAGIC_HOST = host
        StytchMagicLinkApi.initialize(projectID: projectID, secretKey: secret)
    }
    
    private func acceptToken(token: String) {
        self.delegate?.onDeepLinkHandled?()
        self.serverManager.authenticateMagicLink(with: token) { model, error in
            if let error = error {
                self.delegate?.onFailure?(error)
            } else if let model = model {
                self.delegate?.onSuccess?(StytchResult(userId: model.userId, requestId: model.requestId))
                self.clearData()
            }
        }
    }
    
    @objc public func handleMagicLinkUrl(_ url: URL?) -> Bool {
        guard let url = url else { return false }
        
        
        if let token = StytchMagicLink.handleMagicLink(url, scheme: MAGIC_SCHEME, path: StytchConstants.LOGIN_MAGIC_PATH) {
            acceptToken(token: token)
            return true
        }
        
        if let token = StytchMagicLink.handleMagicLink(url, scheme: MAGIC_SCHEME, path: StytchConstants.SIGNUP_MAGIC_PATH) {
            acceptToken(token: token)
            return true
        }
        
        if let token = StytchMagicLink.handleMagicLink(url, scheme: MAGIC_SCHEME, path: StytchConstants.INVITE_MAGIC_PATH) {
            acceptToken(token: token)
            return true
        }
        
        return false
    }
    
    @objc public func login(email: String) {
        
        if !email.isValidEmail {
            self.delegate?.onFailure?(.invalidEmail)
            return
        }
        
        serverManager.sendMagicLink(to: email) { error in
            if let error = error {
                self.delegate?.onFailure?(error)
            } else {
                
                if let userModel = self.serverManager.userResponse {
                    if userModel.userCreated {
                        StytchMagicLinkUI.shared.delegate?.onEvent?(StytchEvent.userCretedEvent(userId: userModel.userId))
                    } else {
                        StytchMagicLinkUI.shared.delegate?.onEvent?(StytchEvent.userFoundEvent(userId: userModel.userId))
                    }
                    
                }
                
                self.delegate?.onMagicLinkSent?(email)
            }
        }
    }
    
    // MARK: Deep link handling
    
    // Check if deep url is intended for StytchSDK and parse token by given sheme
    static func handleMagicLink(_ url: URL?, scheme: String, path: String) -> String? {
        guard let url = url else { return nil }
        
        if let host = url.host, let urlScheme = url.scheme, let token = url.valueOf(StytchConstants.MAGIC_TOKEN_KEY),
           host == StytchMagicLink.shared.MAGIC_HOST,
           url.path == path,
           urlScheme == scheme {
            return token
        }
        
        return nil
    }
}

