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

public extension StytchB2BClient.OTP {
    typealias OTPAuthenticateResponse = Response<OTPAuthenticateResponseData>
    struct OTPAuthenticateResponseData: Codable, Sendable, B2BAuthenticateResponseDataType {
        public let memberSession: MemberSession
        public let member: Member
        public let organization: Organization
        public let sessionToken: String
        public let sessionJwt: String
        public let memberDevice: SDKDeviceHistory?
    }
}
