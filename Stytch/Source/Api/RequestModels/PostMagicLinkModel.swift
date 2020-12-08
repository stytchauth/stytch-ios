//
//  PostMagicLinkModel.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-18.
//

import Foundation

class PostMagicLinkModel: Codable {
    var email: String?
    var magic_link_url: String?
    var expiration_minutes: Int = 5
//    var attrubutes = AttributesModel()
}
