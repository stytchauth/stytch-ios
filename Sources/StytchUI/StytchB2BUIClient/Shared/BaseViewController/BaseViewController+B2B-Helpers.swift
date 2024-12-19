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
            presentAlert(
                title: NSLocalizedString("stytch.vcErrorTitle", value: "Error", comment: ""),
                message: "\(MemberManager.emailAddress ?? "This email") does not have access to \(OrganizationManager.name ?? "this organization"). If you think this is a mistake, contact your admin."
            )
        } else {
            presentErrorAlert(error: error)
        }
    }
}
