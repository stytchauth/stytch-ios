
import Foundation

@objc(SAStytch) public class Stytch: NSObject {

    @objc public static let shared: Stytch = Stytch()
    @objc public let magicLink: StytchMagicLink = StytchMagicLink()
    @objc public let otp: StytchOTP = StytchOTP()

    @objc public var environment: StytchEnvironment = .test{
        didSet{
            magicLink.environment = environment
            otp.environment = environment
        }
    }

    @objc public var `debug`: Bool = false{
        didSet{
            magicLink.debug = debug
            otp.debug = debug
        }
    }

    @objc public var createUserAsPending: Bool = false{
        didSet{
            magicLink.createUserAsPending = createUserAsPending
            otp.createUserAsPending = createUserAsPending
        }
    }

    private override init() {}

    @objc public func configure(projectID: String,
                                scheme: String,
                                host: String) {
        magicLink.configure(projectID: projectID, scheme: scheme, host: host)
        otp.configure(projectID: projectID)
    }

    @objc public func configure(projectID: String,
                                universalLink: URL) {
        magicLink.configure(projectID: projectID, universalLink: universalLink)
        otp.configure(projectID: projectID)
    }

    //For just configuring OTP without Magic Link config.
    @objc public func configure(projectID: String) {
        otp.configure(projectID: projectID)
    }
}
