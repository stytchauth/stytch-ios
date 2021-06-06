//
//  MagicLinkModel.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-18.
//

import Foundation

@objc public class SMSModel: NSObject, Codable {
    
    var userId: String
    var requestId: String
    var phoneId: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case requestId = "request_id"
        case phoneId = "phone_id"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userId = try values.decode(String.self, forKey: .userId)
        requestId = try values.decode(String.self, forKey: .requestId)
        phoneId = try values.decode(String.self, forKey: .phoneId)
    }
}
