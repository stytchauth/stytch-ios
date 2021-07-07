//
//  Stytch.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-24.
//

import UIKit
/*
@objc private protocol StytchMagicLinkImpl {
    @objc static var shared: StytchMagicLink { get }
    @objc func configure(projectID: String, secret: String, scheme: String, host: String)
    @objc func configure(projectID: String, secret: String, scheme: String, host: String, universalLink: String)
    @objc var `debug`: Bool { get set }
    @objc var environment: StytchEnvironment { get set }
    @objc func handleMagicLinkUrl(_ url: URL?) -> Bool
    @objc func login(email: String)
}
*/

@objc(SAStytchMagicLink) public class StytchMagicLink: NSObject {
    
    //@objc public static let shared: StytchMagicLink = StytchMagicLink()
    
    @objc public var environment: StytchEnvironment = .live
    
    @objc public var createUserAsPending: Bool = false

    @objc public var delegate: StytchMagicLinkDelegate?
    
    @objc public var `debug`: Bool = false
    
    internal var loginMagicLink: String {
        if let UNIVERSAL_LINK = UNIVERSAL_LINK{
            return "\(UNIVERSAL_LINK)\(StytchConstants.LOGIN_MAGIC_PATH)"
        }
        return "\(MAGIC_SCHEME)://\(MAGIC_HOST)\(StytchConstants.LOGIN_MAGIC_PATH)"
    }
    
    internal var signUpMagicLink: String {
        if let UNIVERSAL_LINK = UNIVERSAL_LINK{
            return "\(UNIVERSAL_LINK)\(StytchConstants.SIGNUP_MAGIC_PATH)"
        }
        return "\(MAGIC_SCHEME)://\(MAGIC_HOST)\(StytchConstants.SIGNUP_MAGIC_PATH)"
    }
    
    internal var inviteMagicLink: String {
        if let UNIVERSAL_LINK = UNIVERSAL_LINK{
            return "\(UNIVERSAL_LINK)\(StytchConstants.INVITE_MAGIC_PATH)"
        }
        return "\(MAGIC_SCHEME)://\(MAGIC_HOST)\(StytchConstants.INVITE_MAGIC_PATH)"
    }
    
    private var MAGIC_SCHEME = ""
    private var MAGIC_HOST = ""
    private var UNIVERSAL_LINK: URL?
    
    private var serverManager = StytchMagicLinkServerFlowManager()
    
    internal override init() {}
    
    @objc public func configure(projectID: String,
                                secret: String,
                                scheme: String,
                                host: String) {
        self.MAGIC_SCHEME = scheme
        self.MAGIC_HOST = host
        StytchMagicLinkApi.initialize(projectID: projectID, secretKey: secret)
    }

    @objc public func configure(projectID: String,
                                secret: String,
                                universalLink: URL) {
        self.MAGIC_SCHEME = "https"
        self.MAGIC_HOST = universalLink.host ?? ""
        self.UNIVERSAL_LINK = universalLink
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
    
    private func clearData() {
        serverManager = StytchMagicLinkServerFlowManager()
        delegate = nil
    }
    
    @objc public func handleMagicLinkUrl(_ url: URL?) -> Bool {
        guard let url = url else { return false }
        
        
        if let token = handleMagicLink(url, scheme: MAGIC_SCHEME, path: StytchConstants.LOGIN_MAGIC_PATH) {
            acceptToken(token: token)
            return true
        }
        
        if let token = handleMagicLink(url, scheme: MAGIC_SCHEME, path: StytchConstants.SIGNUP_MAGIC_PATH) {
            acceptToken(token: token)
            return true
        }
        
        if let token = handleMagicLink(url, scheme: MAGIC_SCHEME, path: StytchConstants.INVITE_MAGIC_PATH) {
            acceptToken(token: token)
            return true
        }
        
        return false
    }
    
    @objc public func login(email: String, success: @escaping (String) ->(), failure: @escaping (StytchError) ->()){
        
        guard email.isValidEmail else{
            failure(.invalidEmail)
            return
        }
        
        serverManager.sendMagicLink(to: email, createUserAsPending: createUserAsPending) { error in
            if let error = error {
                failure(error)
            } else {
                
                if let userModel = self.serverManager.userResponse {
                    if userModel.userCreated {
                        Stytch.shared.magicLink.delegate?.onEvent?(StytchEvent.userCretedEvent(userId: userModel.userId))
                    } else {
                        Stytch.shared.magicLink.delegate?.onEvent?(StytchEvent.userFoundEvent(userId: userModel.userId))
                    }
                    
                }
                success(email)
            }
        }
    }
    
    // MARK: Deep link handling
    
    // Check if deep url is intended for StytchSDK and parse token by given sheme
    private  func handleMagicLink(_ url: URL?, scheme: String, path: String) -> String? {
        guard let url = url else { return nil }
        
        if let host = url.host, let urlScheme = url.scheme, let token = url.valueOf(StytchConstants.MAGIC_TOKEN_KEY),
           host == Stytch.shared.magicLink.MAGIC_HOST,
           url.path == path,
           urlScheme == scheme {
            return token
        }
        
        return nil
    }
}

