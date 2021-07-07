//
//  StytchServerFlowManager.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-25.
//

import Foundation

class StytchOTPServerFlowManager {

    var userResponse: UserModel?

    var phoneNumber: String = ""
    var methodId: String? = nil
    var lastRecievedSMSModel: SMSModel? = nil

    func sendOTPBySMS(to phoneNumber: String,
                      expirationTime: Int,
                      success: @escaping (SMSModel) ->(),
                      failure: @escaping (StytchError) ->()){
        let request = SendOTPBySMSRequest(phone_number: phoneNumber,
                                          expiration_minutes: expirationTime)

        StytchOTPApi.shared.sendOTPBySMS(model: request) { (respose) in
            if let model = respose.data{
                success(model)
            }else {
                failure(Self.convertError(type: respose.error.errorType))
            }
        }
    }

    func loginOrCreateUserBySMS(to phoneNumber: String,
                                expirationTime: Int,
                                createUserAsPending: Bool,
                                success: @escaping (SMSModel) ->(),
                                failure: @escaping (StytchError) ->()){
        let request = SendOTPBySMSRequest(phone_number: phoneNumber,
                                          expiration_minutes: expirationTime,
                                          create_user_as_pending: createUserAsPending)
        StytchOTPApi.shared.loginOrCreateUserBySMS(model: request) { [weak self] (respose) in
            if let model = respose.data{
                self?.lastRecievedSMSModel = model
                success(model)
            }else {
                failure(Self.convertError(type: respose.error.errorType))
            }
        }
    }

    func authenticateOTP(with code: String,
                         success: @escaping (AuthenticatedOTPResponse) ->(),
                         failure: @escaping (StytchError) ->()){
        guard let methodId = methodId else {
            failure(.unknown)//@Ethan fix this to add the specific error.
            return
        }
        let request = AuthenticateOTPRequest(methodId: methodId, code: code)

        StytchOTPApi.shared.authenticateOTP(model: request) { (respose) in
            if let model = respose.data{
                success(model)
            }else {
                failure(Self.convertError(type: respose.error.errorType))
            }
        }
    }
    private static func convertError(type: ErrorType) -> StytchError {
        switch type {
        case .unknown:
            return StytchError.connection
        case .emailNotFound:
            return StytchError.unknown // Should be handled when sending magic link
        case .duplicateEmail:
            return StytchError.unknown // Should be handled when creating user
        case .unableToAuthMagicLink:
            return StytchError.invalidMagicToken
        case .unauthorizedCredentials:
            return StytchError.invalidConfiguration
        case .internalServerError:
            return StytchError.unknown
        }
    }
}
