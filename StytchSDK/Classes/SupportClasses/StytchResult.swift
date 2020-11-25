//
//  StytchResult.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-25.
//

import Foundation

@objc(StytchResult) public class StytchResult: NSObject {
    
    @objc public var userId: String
    @objc public var requestId: String
    
    init(userId: String, requestId: String) {
        self.userId = userId
        self.requestId = requestId
    }
}
