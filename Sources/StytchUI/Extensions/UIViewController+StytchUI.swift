import StytchCore
import UIKit

extension UIViewController {
    func presentErrorAlert(error: Error) {
        presentAlert(
            title: NSLocalizedString("stytch.vcErrorTitle", value: "Error", comment: ""),
            message: (error as? StytchError)?.message ?? error.localizedDescription
        )
    }

    func presentAlert(title: String?, message: String?) {
        Task { @MainActor [weak self] in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.view.tintColor = .primaryText
            alertController.addAction(.init(title: NSLocalizedString("stytch.vcOK", value: "OK", comment: ""), style: .default))
            self?.present(alertController, animated: true)
        }
    }
}
