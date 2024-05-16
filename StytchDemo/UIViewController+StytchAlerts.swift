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
    
    func presentTextFieldAlertWithTitle(
        alertTitle: String,
        defaultText: String? = nil,
        buttonTitle: String = "Submit",
        completion: ((String) -> ())? = nil
    ) {
        let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        alertController.addTextField()
        alertController.textFields?[0].text = defaultText
        
        let submitAction = UIAlertAction(title: buttonTitle, style: .default) { [unowned alertController] _ in
            if let text = alertController.textFields?[0].text {
                completion?(text)
            }
        }
        alertController.addAction(submitAction)
        present(alertController, animated: true)
    }
    
    func presentErrorWithDescription(error: Error, description: String) {
        presentAlertWithTitle(alertTitle: "\(description) - \(error.errorInfo)")
    }
}
