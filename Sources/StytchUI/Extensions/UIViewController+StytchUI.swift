import StytchCore
import UIKit

extension UIViewController {
    func presentAlert(error: Error) {
        Task { @MainActor in
            let alertController = UIAlertController(
                title: NSLocalizedString("stytch.vcErrorTitle", value: "Error", comment: ""),
                message: (error as? StytchError)?.message ?? error.localizedDescription,
                preferredStyle: .alert
            )
            alertController.view.tintColor = .primaryText
            alertController.addAction(.init(title: NSLocalizedString("stytch.vcOK", value: "OK", comment: ""), style: .default))
            present(alertController, animated: true)
        }
    }
}
