//
//  StytchMagicLinkUI.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-17.
//

import UIKit

@objc(StytchMagicLinkUI) public class StytchMagicLinkUI: NSObject {
    
    @objc public static let shared: StytchMagicLinkUI = StytchMagicLinkUI()
    
    private override init() {}
    
    @objc public let customization = StytchUICustomization()
    
    @objc public var delegate: StytchUIDelegate?
    
    @objc public func loginViewController() -> UIViewController{
        let stytchViewController = MagicLinkInitialViewController()
        let navigationController = UINavigationController(rootViewController: stytchViewController)
        return navigationController
    }
    
}
