import Foundation
import StytchCore

extension StytchB2BUIClient {
    enum MFAManager {
        /// Values from the B2BMFAAuthenticateResponseDataType
        static var memberAuthenticated: Bool = false
        static var mfaRequired: MFARequired?
        static var primaryRequired: PrimaryRequired?

        /// totp related fields
        static var secret: String?
        static var recoveryCodes: [String]?
        static var didSaveRecoveryCodes: Bool = false

        static func updateMFAState(mfaResponse: B2BMFAAuthenticateResponseDataType) {
            memberAuthenticated = mfaResponse.memberAuthenticated
            mfaRequired = mfaResponse.mfaRequired
            primaryRequired = mfaResponse.primaryRequired
        }

        static func updateTotpState(totpResponse: StytchB2BClient.TOTP.CreateResponseData) {
            secret = totpResponse.secret
            recoveryCodes = totpResponse.recoveryCodes
        }

        static func reset() {
            memberAuthenticated = false
            mfaRequired = nil
            primaryRequired = nil
            secret = nil
            recoveryCodes = nil
            didSaveRecoveryCodes = false
        }
    }
}

extension B2BMFAAuthenticateResponseDataType {
    var memberEmailAddress: String? {
        member.emailAddress
    }
}
