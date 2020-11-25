//
//  ErrorResponseModel.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-20.
//

import Foundation

enum ErrorType: String, Codable {
    case unknown = "unknown"
    case emailNotFound = "email_not_found"
    case duplicateEmail = "duplicate_email"
    case unableToAuthMagicLink = "unable_to_auth_magic_link"
    case unauthorizedCredentials = "unauthorized_credentials"
    
    var message: String {
        switch self {
        case .unknown:
            return "Something went wrong"
        case .emailNotFound:
            return "Email could not be found"
        case .duplicateEmail:
            return "A user with the specified email already exists for this project"
        case .unableToAuthMagicLink:
            return "Magic link could not be authenticated"
        case .unauthorizedCredentials:
            return "Unauthorized credentials"
        }
    }
}

class ErrorResponseModel: Codable {
    var status: Int
    var errorType: ErrorType
    
    init (){
        status = -1
        errorType = .unknown
    }
    
    enum CodingKeys: String, CodingKey {
        case status
        case errorType = "error_type"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decode(Int.self, forKey: .status)
        errorType = (try? values.decode(ErrorType.self, forKey: .errorType)) ?? .unknown
    }
}
