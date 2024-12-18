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
}
