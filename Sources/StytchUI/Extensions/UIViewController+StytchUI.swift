import StytchCore
import UIKit

extension UIViewController {
    func presentErrorAlert(error: Error) {
        presentAlert(
            title: LocalizationManager.stytch_error_alert_title,
            message: error.getLocalizedErrorMessage() ?? (error as? StytchError)?.message ?? error.localizedDescription
        )
    }

    func presentAlert(title: String?, message: String? = nil) {
        Task { @MainActor in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.view.tintColor = .primaryText
            alertController.addAction(.init(title: LocalizationManager.stytch_alert_ok, style: .default))
            present(alertController, animated: true)
        }
    }

    func presentShareSheet(text: String) {
        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)

        // For iPads, you need to set the popoverPresentationController source
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        present(activityViewController, animated: true, completion: nil)
    }
}
