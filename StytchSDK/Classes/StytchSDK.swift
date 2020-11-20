//
//  StytchSDK.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-17.
//

import UIKit

@objc(StytchSDK) public class StytchSDK: NSObject {
    
    @objc public static let shared: StytchSDK = StytchSDK()
    
    var magicScheme = "exampleapp"
    let magicHost = "stytch.com"
    let magicPath = "/magic_happened"
    
    let MAGIC_TOKEN_KEY = "token"
    
    var magicLink: String {
        return "\(magicScheme)://\(magicHost)\(magicPath)"
    }
    
    var delegate: StytchSDKDelegate?
    
    private override init() {
    
    }
    
    @objc public func start(from presenter: UIViewController, delegate: StytchSDKDelegate) {
        self.delegate = delegate
        let stytchViewController = StytchAuthViewController()
        stytchViewController.modalPresentationStyle = .fullScreen
        presenter.present(stytchViewController, animated: true, completion: nil)
    }
    
    @objc public func handleMagicLinkUrl(_ url: URL?) -> Bool {
        guard let url = url else { return false }
        
        if let host = url.host, let scheme = url.scheme, let token = url.valueOf(MAGIC_TOKEN_KEY),
           host == magicHost,
           url.path == magicPath,
           scheme == magicScheme {
            StytchModelViewController.shared.authenticateMagcLink(with: token)
        }
        
        return true
    }

}
