//
//  StytchUI.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-17.
//

import UIKit

@objc(StytchUI) public class StytchUI: NSObject {
    
    @objc public static let shared: StytchUI = StytchUI()
    
    private override init() {}
    
    @objc public let customization = StytchUICustomization()
    
    var delegate: StytchUIDelegate?
    
    @objc public func showUI(from presenter: UIViewController, delegate: StytchUIDelegate) {
        self.delegate = delegate
        let stytchViewController = StytchAuthViewController()
        stytchViewController.modalPresentationStyle = .fullScreen
        let navigationController = UINavigationController(rootViewController: stytchViewController)
        presenter.present(navigationController, animated: true, completion: nil)
    }
    
}
