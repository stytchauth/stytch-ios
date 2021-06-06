//
//  StytchMagicLinkApi.swift
//  Stytch
//
//  Created by Ethan Furstoss on 1/3/21.
//

import Foundation

class StytchOTPApi {

    static private(set) var shared: StytchOTPApi = StytchOTPApi()

    static func initialize(projectID: String, secretKey: String) {
        let api = StytchOTPApi()
        api.projectID = projectID
        api.secretKey = secretKey
        StytchOTPApi.shared = api
    }

    private var host: String {
        switch StytchOTP.shared.environment {
        case .test:
            return "https://test.stytch.com\(StytchConstants.SERVER_VERSION)"
        case .live:
            return "https://api.stytch.com\(StytchConstants.SERVER_VERSION)"
        }

    }

    private let authKey = "Authorization"
    private var projectID = ""
    private var secretKey = ""

    private var authHeader: [String: String] {
        let value = "\(projectID):\(secretKey)"

        let utf8str = value.data(using: .utf8)?.base64EncodedString() ?? ""

        return [authKey : "Basic \(utf8str)"]
    }

    private init() {}

    func sendOTPBySMS(model: SendOTPBySMSRequest, handler: @escaping (BaseResponseModel<SMSModel>) -> ()) {
        let request = BaseRequest<SendOTPBySMSRequest, SMSModel>
            .init(URL(string: host + "/otp/send_by_sms")!, method: .POST, object: model,
                  headers: authHeader)

        request.send(handler: handler)
    }

    func loginOrCreateUserBySMS(model: SendOTPBySMSRequest, handler: @escaping (BaseResponseModel<SMSModel>) -> ()) {
        let request = BaseRequest<SendOTPBySMSRequest, SMSModel>
            .init(URL(string: host + "/otp/login_or_create")!, method: .POST, object: model,
                  headers: authHeader)

        request.send(handler: handler)
    }

    func authenticateOTP(model: AuthenticateOTPRequest, handler: @escaping (BaseResponseModel<AuthenticatedOTPResponse>) -> ()) {
        let request = BaseRequest<AuthenticateOTPRequest, AuthenticatedOTPResponse>
            .init(URL(string: host + "/otp/authenticate")!, method: .POST, object: model,
                  headers: authHeader)

        request.send(handler: handler)
    }
}
