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
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case emailId = "email_id"
        case requestId = "request_id"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userId = try values.decode(String.self, forKey: .userId)
        emailId = try values.decode(String.self, forKey: .emailId)
        requestId = try values.decode(String.self, forKey: .requestId)
    }
}
