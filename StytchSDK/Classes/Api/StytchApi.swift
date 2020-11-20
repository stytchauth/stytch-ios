//
//  StytchApi.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-18.
//

import Foundation

class StytchApi {
    
    static let shared = StytchApi()
    
    let host = "https://test.stytch.com/v1"
    
    let authKey = "Authorization"
    let projectID = "project-test-d0dbafe6-a019-47ea-8550-d021c1c76ea9"
    let secretKey = "secret-test-6-ma0PNENqjBVX6Dx2aPUIdhLFObauXx07c="
    
    var authHeader: [String: String] {
        let value = "\(projectID):\(secretKey)"
        
        let utf8str = value.data(using: .utf8)?.base64EncodedString() ?? ""
        
        return [authKey : "Basic \(utf8str)"]
    }
    
    private init() {}
    
    func createUser(model: PostCreateUserModel, handler: @escaping (BaseResponseModel<UserModel>) -> ()) {
        let request = BaseRequest<PostCreateUserModel, UserModel>
            .init(URL(string: host + "/users")!, method: .POST, object: model,
                  headers: authHeader)
        
        request.send(handler: handler)
    }
    
    func sendMagicLink(model: PostMagicLinkModel, handler: @escaping (BaseResponseModel<MagicLinkModel>) -> ()) {
        let request = BaseRequest<PostMagicLinkModel, MagicLinkModel>
            .init(URL(string: host + "/magic_links/send_by_email")!, method: .POST, object: model,
                  headers: authHeader)
        
        request.send(handler: handler)
    }
    
    func authenticateMagicLink(token: String, handler: @escaping (BaseResponseModel<MagicLinkModel>) -> ()) {
        let request = BaseRequest<EmptyModel, MagicLinkModel>
            .init(URL(string: host + "/magic_links/\(token)/authenticate")!, method: .POST, object: EmptyModel(),
                  headers: authHeader)
        
        request.send(handler: handler)
    }
}
