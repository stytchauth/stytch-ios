import Foundation
import StytchCore
import UIKit

enum B2BAuthenticationManager {
    /// Values from the B2BMFAAuthenticateResponseDataType
    static var b2bMFAAuthenticateResponse: B2BMFAAuthenticateResponseDataType?
    static var primaryRequired: StytchB2BClient.PrimaryRequired? {
        b2bMFAAuthenticateResponse?.primaryRequired
    }

    /// totp related fields
    static var secret: String?
    static var recoveryCodes: [String]?
    static var didSaveRecoveryCodes: Bool = false

    static func handleMFAReponse(b2bMFAAuthenticateResponse: B2BMFAAuthenticateResponseDataType) {
        Self.b2bMFAAuthenticateResponse = b2bMFAAuthenticateResponse
        OrganizationManager.updateOrganization(b2bMFAAuthenticateResponse.organization)
        MemberManager.updateMember(b2bMFAAuthenticateResponse.member)
    }

    static func handleSecondaryReponse(b2bAuthenticateResponse: B2BAuthenticateResponseDataType) {
        print(b2bAuthenticateResponse.memberSession)
    }

    static func updateTotpState(totpResponse: StytchB2BClient.TOTP.CreateResponseData) {
        secret = totpResponse.secret
        recoveryCodes = totpResponse.recoveryCodes
    }

    static func reset() {
        b2bMFAAuthenticateResponse = nil
        secret = nil
        recoveryCodes = nil
        didSaveRecoveryCodes = false
    }
}
