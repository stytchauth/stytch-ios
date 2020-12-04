//
//  StytchEvent.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-25.
//

import Foundation

@objc(StytchEvent) public class StytchEvent: NSObject {
    
    @objc public var type: String
    @objc public var created: Bool
    @objc public var userId: String
    
    private init(type: String, created: Bool, userId: String) {
        self.type = type
        self.created = created
        self.userId = userId
    }
    
    static func userCretedEvent(userId: String) -> StytchEvent {
        return StytchEvent(type: "user_event", created: true, userId: userId)
    }
    
    static func userFoundEvent(userId: String) -> StytchEvent {
        return StytchEvent(type: "user_event", created: false, userId: userId)
    }
}
