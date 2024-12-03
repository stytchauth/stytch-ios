import Foundation
import StytchCore
import UIKit

enum B2BAuthenticationManager {
    /// Values from the B2BMFAAuthenticateResponseDataType
    static var b2bMFAAuthenticateResponse: B2BMFAAuthenticateResponseDataType?
    static var primaryRequired: PrimaryRequired? {
        b2bMFAAuthenticateResponse?.primaryRequired
    }

    /// totp related fields
    static var secret: String?
    static var recoveryCodes: [String]?
    static var didSaveRecoveryCodes: Bool = false

    static func handleMFAReponse(b2bMFAAuthenticateResponse: B2BMFAAuthenticateResponseDataType) {
        Self.b2bMFAAuthenticateResponse = b2bMFAAuthenticateResponse
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

extension BaseViewController {
    func startMFAFlowIfNeeded(configuration: StytchB2BUIClient.Configuration) {
        var viewController: UIViewController?

        let b2bMFAAuthenticateResponse = B2BAuthenticationManager.b2bMFAAuthenticateResponse

        if b2bMFAAuthenticateResponse?.primaryRequired != nil {
            // not sure what happens here yet
        } else if b2bMFAAuthenticateResponse?.member.mfaEnrolled == true {
            if b2bMFAAuthenticateResponse?.mfaRequired?.memberOptions?.mfaPhoneNumber != nil {
                viewController = SMSOTPEntryViewController(state: .init(configuration: configuration))
            } else if b2bMFAAuthenticateResponse?.mfaRequired?.memberOptions?.totpRegistrationId == nil {
                viewController = TOTPEntryViewController(state: .init(configuration: configuration))
            }
        } else {
            if b2bMFAAuthenticateResponse?.organization.usesSMSAndTOTPMFA == true {
                viewController = MFAEnrollmentSelectionViewController(state: .init(configuration: configuration))
            } else if b2bMFAAuthenticateResponse?.organization.usesSMSMFAOnly == true {
                viewController = SMSOTPEnrollmentViewController(state: .init(configuration: configuration))
            } else if b2bMFAAuthenticateResponse?.organization.usesTOTPMFAOnly == true {
                viewController = TOTPEnrollmentViewController(state: .init(configuration: configuration))
            }
        }

        if let viewController {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
