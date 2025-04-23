import StytchCore
import UIKit

extension BaseViewController {
    func showEmailConfirmation(configuration: StytchB2BUIClient.Configuration, type: EmailConfirmationType) {
        Task { @MainActor in
            let emailConfirmationViewController = EmailConfirmationViewController(state: .init(configuration: configuration, type: type))
            navigationController?.pushViewController(emailConfirmationViewController, animated: true)
        }
    }

    func showError(configuration: StytchB2BUIClient.Configuration, type: ErrorScreenType) {
        Task { @MainActor in
            let emailConfirmationViewController = ErrorViewController(state: .init(configuration: configuration, type: type))
            navigationController?.pushViewController(emailConfirmationViewController, animated: true)
        }
    }

    func showEmailNotEligibleForJitProvioningErrorIfPossible(_ error: any Error) {
        if let error = error as? StytchSDKError, error == .emailNotEligibleForJitProvioning {
            ErrorPublisher.publishError(error)
            let messsage = LocalizationManager.stytch_b2b_email_not_eligible_for_jit_provioning_error(memberEmail: MemberManager.emailAddress ?? "This email", orgName: OrganizationManager.name ?? "this organization")
            presentAlert(
                title: LocalizationManager.stytch_b2c_error_title,
                message: messsage
            )
        } else {
            ErrorPublisher.publishError(error)
            presentErrorAlert(error: error)
        }
    }
}
