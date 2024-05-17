import Foundation
import UIKit
import StytchCore

extension UIViewController {
    func presentAlertWithTitle(
        alertTitle: String,
        buttonTitle: String = "OK",
        completion: (() -> ())? = nil
    ) {
        let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: buttonTitle, style: .cancel) { _ in
            completion?()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    func presentErrorWithDescription(error: Error, description: String) {
        presentAlertWithTitle(alertTitle: "\(description) - \(error.errorInfo)")
    }
}
