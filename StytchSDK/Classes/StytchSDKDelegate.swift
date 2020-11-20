//
//  StytchSDKDelegate.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-20.
//

import Foundation

@objc(StytchSDKDelegate) public protocol StytchSDKDelegate {
    
    @objc func onEvent(_ event: StytchEvent)
    @objc func onSuccess(requstId: String, userId: String)
    @objc func onFailure()
    
}

@objc(StytchEvent) public class StytchEvent: NSObject {
    
    var userId: String
    
    init(userId: String) {
        self.userId = userId
    }
}
