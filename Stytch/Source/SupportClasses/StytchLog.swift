//
//  StytchLog.swift
//  Stytch
//
//  Created by Edgar Kroman on 2020-12-07.
//

import Foundation

class StytchLog: NSObject {
    
    static func show(_ items: Any...) {
        if Stytch.shared.debug {
            #if DEBUG
            print("[Stytch]  ", separator: " ", terminator: " ")
            for item in items {
                print(item, separator: " ", terminator: " ")
            }
            print("")
            #endif
        }
    }
}
