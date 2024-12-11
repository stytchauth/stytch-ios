import Foundation
import StytchCore
import UIKit

extension BaseViewController {
    func startMFAFlowIfNeeded(configuration: StytchB2BUIClient.Configuration) {
        Task { @MainActor in
            var viewController: UIViewController?

            let b2bMFAAuthenticateResponse = B2BAuthenticationManager.b2bMFAAuthenticateResponse

            if b2bMFAAuthenticateResponse?.primaryRequired != nil {
                viewController = B2BAuthHomeViewController(state: .init(configuration: configuration))
            } else if b2bMFAAuthenticateResponse?.member.mfaEnrolled == true {
                if b2bMFAAuthenticateResponse?.mfaRequired?.secondaryAuthInitiated == "sms_otp" {
                    viewController = SMSOTPEntryViewController(state: .init(configuration: configuration))
                } else if b2bMFAAuthenticateResponse?.mfaRequired?.memberOptions?.totpRegistrationId != nil {
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

    func showEmailConfirmation(configuration: StytchB2BUIClient.Configuration, type: EmailConfirmationType) {
        Task { @MainActor in
            let emailConfirmationViewController = EmailConfirmationViewController(state: .init(configuration: configuration, type: type))
            navigationController?.pushViewController(emailConfirmationViewController, animated: true)
        }
    }
}
