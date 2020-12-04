//
//  StytchLoginResult.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-24.
//

import Foundation

@objc(StytchLoginResult) public enum StytchLoginResult: Int {
    case userCreated
    case userFound
    case error
}
