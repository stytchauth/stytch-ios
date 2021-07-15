import UIKit
/*
@objc private protocol StytchMagicLinkImpl {
    @objc static var shared: StytchMagicLink { get }
    @objc func configure(projectID: String, secret: String, scheme: String, host: String)
    @objc func configure(projectID: String, secret: String, scheme: String, host: String, universalLink: String)
    @objc var `debug`: Bool { get set }
    @objc var environment: StytchEnvironment { get set }
    @objc var loginMethod: StytchLoginMethod { get set }
    @objc func handleMagicLinkUrl(_ url: URL?) -> Bool
    @objc func login(email: String)
}
*/
@objc(SAStytchOTPAuthenticator) public protocol StytchOTPAuthenticator {
    //@TODO I probably need to provide more than just the code to clients in order for them to auth.
    //"method_id": "phone-number-test-d5a3b680-e8a3-40c0-b815-ab79986666d0",
    //"code": "123456"
    func authenticateOTP(_ code: String, methodId: String, success: @escaping (AuthenticatedOTPResponse) ->(), failure: @escaping (StytchError) ->())
}

@objc(SAStytchOTP) public class StytchOTP: NSObject {

    //@objc public static let shared: StytchOTP = StytchOTP()
    @objc public var environment: StytchEnvironment = .live

    @objc public var createUserAsPending: Bool = false

    @objc public var `debug`: Bool = false

    @objc public var otpAuthenticator: StytchOTPAuthenticator?

    @objc public static let codeLength = 6


    private var serverManager = StytchOTPServerFlowManager()

    internal override init() {}

    @objc public func configure(projectID: String) {
        StytchOTPApi.initialize(projectID: projectID)
    }

    private func clearData() {
        serverManager = StytchOTPServerFlowManager()
    }


    @objc private func sendOTPBySMS(phoneNumber: String,
                                   expirationTime: Int = 2,
                                   success: @escaping (SMSModel) ->(),
                                   failure: @escaping (StytchError) ->()){


        guard phoneNumber.isValidPhoneNumber else{
            //@TODO create invalid phone number error
            failure(.invalidEmail)
            return
        }
        serverManager.sendOTPBySMS(to: phoneNumber, expirationTime: expirationTime, success: success, failure: failure)
    }


    @objc public func loginOrCreateUserBySMS(phoneNumber: String,
                                expirationTime: Int = 2,
                                createUserAsPending: Bool,
                                success: @escaping (SMSModel) ->(),
                                failure: @escaping (StytchError) ->()){

        guard phoneNumber.isValidPhoneNumber else{
            failure(.invalidPhoneNumber)
            return
        }

        serverManager.loginOrCreateUserBySMS(to: phoneNumber, expirationTime: expirationTime, createUserAsPending: createUserAsPending, success: success, failure: failure)
    }

    @objc internal func authenticateOTP(_ code: String, success: @escaping (AuthenticatedOTPResponse) ->(), failure: @escaping (StytchError) ->()){
        guard code.isValidOTP else{
            failure(.invalidPhoneNumber)
            return
        }

        guard let otpAuthenticator = otpAuthenticator else {
            failure(.missingDeveloperDependency)
            return
        }

        guard let smsModel = serverManager.lastRecievedSMSModel else {
            return
        }

        otpAuthenticator.authenticateOTP(code, methodId: smsModel.phoneId, success: success, failure: failure)
    }




}
