import Foundation
import StytchCore
import UIKit

extension UIViewController {
    func presentAlertWithTitle(
        alertTitle: String,
        buttonTitle: String = "OK",
        completion: (() -> Void)? = nil
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

    func presentAlertAndLogMessage(description: String, object: Any) {
        if let error = object as? Error {
            presentAlertWithTitle(alertTitle: "\(description)\n\ncheck logs for more info")
            print("\(description)\n\(error.errorInfo)\n")
        } else {
            presentAlertWithTitle(alertTitle: "\(description)\n\ncheck logs for more info")
            print("\(description)\n\(object)\n")
        }
    }
}

extension UIButton {
    convenience init(title: String, primaryAction: UIAction) {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = title
        self.init(configuration: configuration, primaryAction: primaryAction)
    }
}

extension UITextField {
    convenience init(title: String, primaryAction: UIAction, keyboardType: UIKeyboardType = .default, password: Bool = false) {
        self.init(frame: .zero, primaryAction: primaryAction)
        borderStyle = .roundedRect
        placeholder = title
        autocorrectionType = .no
        autocapitalizationType = .none
        self.keyboardType = keyboardType
        if password == true {
            textContentType = .password
        }
    }
}

extension UIStackView {
    static func stytchB2BStackView() -> UIStackView {
        let view = UIStackView()
        view.layoutMargins = Constants.insets
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        view.distribution = .fillEqually
        view.spacing = 8
        return view
    }
}
