//
//  StytchEvent.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-25.
//

import Foundation

@objc(StytchEvent) public class StytchEvent: NSObject {
    
    var userId: String
    
    init(userId: String) {
        self.userId = userId
    }
}
