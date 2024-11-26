import Foundation
import StytchCore

extension StytchB2BUIClient {
    enum MFAManager {
        static var mfaRequired: MFARequired?
        static var primaryRequired: PrimaryRequired?
        static func updateMFAState(mfaResponse: B2BMFAAuthenticateResponseDataType) {
            mfaRequired = mfaResponse.mfaRequired
            primaryRequired = mfaResponse.primaryRequired
        }
    }
}
