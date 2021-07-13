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
    case invalidPhoneNumber
    case connection
    case invalidMagicToken
    case invalidConfiguration
    case missingDeveloperDependency
    
    var message: String {
        switch self {
        case .unknown:
            return "stytch_error_unknown".localized
        case .invalidEmail:
            return "stytch_error_invalid_input".localized
        case .connection:
            return "stytch_error_no_internet".localized
        case .invalidMagicToken:
            return "stytch_error_invalid_magic_token".localized
        case .invalidConfiguration:
            return "stytch_error_bad_token".localized
        case .invalidPhoneNumber:
            return "stytch_error_invalid_phone_number".localized
        case .missingDeveloperDependency:
            return "stytch_error_missing_dependency".localized

        }
    }
}
