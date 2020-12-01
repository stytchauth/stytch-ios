//
//  StytchError.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-25.
//

import Foundation

@objc(StytchError) public enum StytchError: Int {
    case unknown
    case invalidEmail
    case connection
    case invalidMagicToken
//    case invalidEmailToken
    case invalidConfiguration
    
    var message: String {
        switch self {
        case .unknown:
            return "Something went wrong"
        case .invalidEmail:
            return "Wrong email format"
        case .connection:
            return "Could not connect to the server"
        case .invalidMagicToken:
            return "Magic link could not be authenticated"
//        case .invalidEmailToken:
//            return "Email verification link could not be authenticated"
        case .invalidConfiguration:
            return "Bad SDK configuration"
        }
    }
}
