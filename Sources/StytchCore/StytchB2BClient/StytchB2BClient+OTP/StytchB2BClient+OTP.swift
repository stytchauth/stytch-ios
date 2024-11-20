import Foundation

public extension StytchB2BClient {
    /// The interface for interacting with otp products.
    static var otp: OTP {
        .init(router: router.scopedRouter {
            $0.otp
        })
    }
}

public extension StytchB2BClient {
    struct OTP {
        let router: NetworkingRouter<StytchB2BClient.OTPRoute>
    }
}
