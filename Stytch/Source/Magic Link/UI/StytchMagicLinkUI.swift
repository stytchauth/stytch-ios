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
    
    @objc public func showUI(from presenter: UIViewController) {
        let stytchViewController = MagicLinkInitialViewController()
        stytchViewController.modalPresentationStyle = .fullScreen
        let navigationController = UINavigationController(rootViewController: stytchViewController)
        presenter.present(navigationController, animated: true, completion: nil)
    }
    
}
