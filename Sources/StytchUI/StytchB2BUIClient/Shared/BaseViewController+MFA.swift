import Foundation
import StytchCore
import UIKit

extension BaseViewController {
    func startMFAFlowIfNeeded(configuration: StytchB2BUIClient.Configuration) {
        var viewController: UIViewController?

        let b2bMFAAuthenticateResponse = B2BAuthenticationManager.b2bMFAAuthenticateResponse

        if b2bMFAAuthenticateResponse?.primaryRequired != nil {
            viewController = B2BAuthHomeViewController(state: .init(configuration: configuration))
        } else if b2bMFAAuthenticateResponse?.member.mfaEnrolled == true {
            if b2bMFAAuthenticateResponse?.mfaRequired?.memberOptions?.mfaPhoneNumber != nil {
                viewController = SMSOTPEntryViewController(state: .init(configuration: configuration))
            } else if b2bMFAAuthenticateResponse?.mfaRequired?.memberOptions?.totpRegistrationId == nil {
                viewController = TOTPEntryViewController(state: .init(configuration: configuration))
            }
        } else {
            if b2bMFAAuthenticateResponse?.organization.allMFAMethodsAllowed == true {
                viewController = MFAEnrollmentSelectionViewController(state: .init(configuration: configuration))
            } else if b2bMFAAuthenticateResponse?.organization.usesSMSMFAOnly == true {
                navigationController?.pushViewController(SMSOTPEnrollmentViewController(state: .init(configuration: configuration)), animated: true)
            } else if b2bMFAAuthenticateResponse?.organization.usesTOTPMFAOnly == true {
                navigationController?.pushViewController(TOTPEnrollmentViewController(state: .init(configuration: configuration)), animated: true)
            }
        }

        if let viewController {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
