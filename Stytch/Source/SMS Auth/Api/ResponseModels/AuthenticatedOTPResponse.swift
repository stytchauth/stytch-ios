//
//  AuthenticatedOTPResponse.swift
//  Stytch
//
//  Created by Ethan Furstoss on 5/19/21.
//

import Foundation

@objc public class AuthenticatedOTPResponse: NSObject, Codable {

    var userId: String
    var requestId: String
    var methodId: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case requestId = "request_id"
        case methodId = "method_id"
    }

    public init(userId: String, requestId: String, methodId: String){
        self.userId = userId
        self.requestId = requestId
        self.methodId = methodId
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userId = try values.decode(String.self, forKey: .userId)
        requestId = try values.decode(String.self, forKey: .requestId)
        methodId = try values.decode(String.self, forKey: .methodId)
    }
}
