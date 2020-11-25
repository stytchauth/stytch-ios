//
//  Stytch.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-24.
//

import UIKit

@objc(Stytch) public class Stytch: NSObject {
    
    @objc public static let shared: Stytch = Stytch()
    
    private override init() {}
    
    var magicScheme = ""
    var verifyNewUserEmail: Bool = false
    
    var serverManager = StytchServerFlowManager()
    
    var magicLink: String {
        return "\(magicScheme)://\(StytchConstants.MAGIC_HOST)\(StytchConstants.MAGIC_PATH)"
    }
    
    var emailVerificationLink: String {
        return "\(magicScheme)://\(StytchConstants.MAGIC_HOST)\(StytchConstants.EMAIL_VERIFICATION_PATH)"
    }

    @objc var delegate: StytchDelegate?
    
    @objc public func configure(projectID: String, secret: String, scheme: String, verifyNewUserEmail: Bool = false) {
        self.magicScheme = scheme
        self.verifyNewUserEmail = verifyNewUserEmail
        StytchApi.initialize(projectID: projectID, secretKey: secret)
    }
    
    @objc public func handleMagicLinkUrl(_ url: URL?) -> Bool {
        guard let url = url else { return false }
        
        
        if let token = Stytch.handleMagicLink(url, scheme: magicScheme, path: StytchConstants.EMAIL_VERIFICATION_PATH) {
            // Send verify email
            return true
        }
        
        if let token = Stytch.handleMagicLink(url, scheme: magicScheme, path: StytchConstants.MAGIC_PATH) {
            self.delegate?.onDeepLinkHandled?()
            self.serverManager.authenticateMagicLink(with: token) { model, error in
                if let error = error {
                    self.delegate?.onFailure?(error)
                } else if let model = model {
                    self.delegate?.onSuccess?(StytchResult(userId: model.userId, requestId: model.requestId))
                }
            }
            return true
        }
        
        return false
    }
    
    @objc public func login(email: String) {
        
        if !email.isValidEmail {
            self.delegate?.onFailure?(.invalidEmail)
            return
        }
        
        #warning("Wrap method, can be verification email sent")
        serverManager.sendMagicLink(to: email) { error in
            if let error = error {
                self.delegate?.onFailure?(error)
            } else {
                self.delegate?.onMagicLinkSent?(email)
            }
        }
    }
    
    // MARK: Deep link handling
    
    // Check if deep url is intended for StytchSDK and parse token by given sheme
    static func handleMagicLink(_ url: URL?, scheme: String, path: String) -> String? {
        guard let url = url else { return nil }
        
        if let host = url.host, let urlScheme = url.scheme, let token = url.valueOf(StytchConstants.MAGIC_TOKEN_KEY),
           host == StytchConstants.MAGIC_HOST,
           url.path == path,
           urlScheme == scheme {
            return token
        }
        
        return nil
    }
}

