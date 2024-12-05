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
                handleSMSOTPEnrollment(configuration: configuration)
            } else if b2bMFAAuthenticateResponse?.organization.usesTOTPMFAOnly == true {
                handleTOTPEnrollment(configuration: configuration)
            }
        }

        if let viewController {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension BaseViewController {
    func handleTOTPEnrollment(configuration: StytchB2BUIClient.Configuration) {
        Task { [weak self] in
            do {
                let secret = try await AuthenticationOperations.createTOTP()
                self?.showTOTPEnrollment(configuration: configuration, secret: secret)
            } catch {
                self?.presentErrorAlert(error: error)
            }
        }
    }

    func showTOTPEnrollment(configuration: StytchB2BUIClient.Configuration, secret: String) {
        let state = TOTPEnrollmentState(configuration: configuration, secret: secret)
        Task { @MainActor in
            navigationController?.pushViewController(TOTPEnrollmentViewController(state: state), animated: true)
        }
    }
}

extension BaseViewController {
    func handleSMSOTPEnrollment(configuration _: StytchB2BUIClient.Configuration) {}
}
