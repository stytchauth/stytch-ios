
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

    @objc public func configure(publicToken: String,
                                scheme: String,
                                host: String) {
        magicLink.configure(publicToken: publicToken, scheme: scheme, host: host)
        otp.configure(projectID: publicToken)
    }

    @objc public func configure(publicToken: String,
                                universalLink: URL) {
        magicLink.configure(publicToken: publicToken, universalLink: universalLink)
        otp.configure(projectID: publicToken)
    }

    //For just configuring OTP without Magic Link config.
    @objc public func configure(projectID: String) {
        otp.configure(projectID: projectID)
    }
}
