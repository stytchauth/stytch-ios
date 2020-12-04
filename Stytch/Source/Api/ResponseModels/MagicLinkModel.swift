//
//  MagicLinkModel.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-18.
//

import Foundation

class MagicLinkModel: Codable {
    
    var userId: String
    var requestId: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case requestId = "request_id"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userId = try values.decode(String.self, forKey: .userId)
        requestId = try values.decode(String.self, forKey: .requestId)
    }
}
