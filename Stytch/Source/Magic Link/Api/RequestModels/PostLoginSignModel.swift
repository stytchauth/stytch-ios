//
//  PostLoginSignModel.swift
//  Stytch
//
//  Created by Edgar Kroman on 2020-12-07.
//

import Foundation

class PostLoginSignModel: Codable {
    var public_token: String
    var request: Request
//    var attrubutes = AttributesModel()
    
    init(email: String, createUserAsPending: Bool, publicToken: String) {
        self.request = Request(email: email, createUserAsPending: createUserAsPending)
        self.public_token = publicToken
    }
}

class Request: Codable {
    var email: String?
    var login_magic_link_url: String = Stytch.shared.magicLink.loginMagicLink
    var signup_magic_link_url: String = Stytch.shared.magicLink.signUpMagicLink
    var login_expiration_minutes: Int = 60
    var signup_expiration_minutes: Int = 60 * 24 * 7
    var create_user_as_pending: Bool = false
//    var attrubutes = AttributesModel()
    
    init(email: String, createUserAsPending: Bool) {
        self.email = email
        self.create_user_as_pending = createUserAsPending
    }
}
