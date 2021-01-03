//
//  StytchUIDelegate.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-20.
//

import Foundation

@objc(StytchSDKDelegate) public protocol StytchUIDelegate {
    
    @objc optional func onEvent(_ event: StytchEvent)
    @objc func onSuccess(_ result: StytchResult)
    @objc func onFailure()
    
}

