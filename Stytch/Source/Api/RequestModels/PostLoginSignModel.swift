//
//  PostLoginSignModel.swift
//  Stytch
//
//  Created by Edgar Kroman on 2020-12-07.
//

import Foundation

class PostLoginSignModel: Codable {
    var email: String?
    var login_magic_link_url: String = Stytch.shared.loginMagicLink
    var signup_magic_link_url: String = Stytch.shared.signUpMagicLink
    var login_expiration_minutes: Int = 60
    var signup_expiration_minutes: Int = 60 * 24 * 7
//    var attrubutes = AttributesModel()
    
    init(email: String) {
        self.email = email
    }
}
