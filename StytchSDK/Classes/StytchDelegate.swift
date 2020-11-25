//
//  StytchDelegate.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-25.
//

import Foundation

@objc(StytchDelegate) public protocol StytchDelegate {
    
    @objc optional func onSuccess(_ result: StytchResult)
    @objc optional func onFailure(_ error: StytchError)
    @objc optional func onVerifcationEmailLinkSent(_ email: String)
    @objc optional func onMagicLinkSent(_ email: String)
    @objc optional func onDeepLinkHandled()
    
}
