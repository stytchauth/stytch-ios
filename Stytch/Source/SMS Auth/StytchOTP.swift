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

@objc(SAStytchOTP) public class StytchOTP: NSObject {

    @objc public static let shared: StytchOTP = StytchOTP()

    @objc public var environment: StytchEnvironment = .live
    @objc public var loginMethod: StytchLoginMethod = .loginOrSignUp

  //  @objc public var delegate: StytchMagicLinkDelegate?

    @objc public var `debug`: Bool = false


    private var serverManager = StytchOTPServerFlowManager()

    private override init() {}

    @objc public func configure(projectID: String,
                                secret: String) {
        StytchOTPApi.initialize(projectID: projectID, secretKey: secret)
    }

    private func clearData() {
        serverManager = StytchOTPServerFlowManager()
    }


    @objc public func sendOTPBySMS(phoneNumber: String,
                                   expirationTime: Int = 2,
                                   success: @escaping (SMSModel) ->(),
                                   failure: @escaping (StytchError) ->()){


        guard phoneNumber.isValidPhoneNumber else{
            //@Ethan create invalid phone number error
            failure(.invalidEmail)
            return
        }
        serverManager.sendOTPBySMS(to: phoneNumber, expirationTime: expirationTime, success: success, failure: failure)
    }


    @objc public func loginOrCreateUserBySMS(phoneNumber: String,
                                expirationTime: Int = 2,
                                success: @escaping (SMSModel) ->(),
                                failure: @escaping (StytchError) ->()){

        guard phoneNumber.isValidPhoneNumber else{
            //@Ethan create invalid phone number error
            failure(.invalidEmail)
            return
        }

        serverManager.loginOrCreateUserBySMS(to: phoneNumber, expirationTime: expirationTime, success: success, failure: failure)
    }

    @objc public func authenticateOTP(_ code: String, success: @escaping (AuthenticatedOTPResponse) ->(), failure: @escaping (StytchError) ->()){
        guard code.isValidOTP else{
            //@Ethan create invalid phone number error
            failure(.invalidEmail)
            return
        }
        serverManager.authenticateOTP(with: code, success: success, failure: failure)
    }




}
