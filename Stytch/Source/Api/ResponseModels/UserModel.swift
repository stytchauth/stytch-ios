//
//  UserModel.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-18.
//

import Foundation

class UserModel: Codable {
    
    var userId: String
    var emailId: String
    var requestId: String
    var userCreated: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case emailId = "email_id"
        case requestId = "request_id"
        case userCreated = "user_created"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userId = try values.decode(String.self, forKey: .userId)
        emailId = try values.decode(String.self, forKey: .emailId)
        requestId = try values.decode(String.self, forKey: .requestId)
        userCreated = try values.decodeIfPresent(Bool.self, forKey: .userCreated) ?? false
    }
}
