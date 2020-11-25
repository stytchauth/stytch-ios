//
//  StytchApi.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-18.
//

import Foundation

class StytchApi {
    
    static private(set) var shared: StytchApi = StytchApi()
    
    static func initialize(projectID: String, secretKey: String) {
        let api = StytchApi()
        api.projectID = projectID
        api.secretKey = secretKey
        StytchApi.shared = api
    }
    
    private let host = "https://test.stytch.com/v1"
    
    private let authKey = "Authorization"
    private var projectID = ""
    private var secretKey = ""
    
    private var authHeader: [String: String] {
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
