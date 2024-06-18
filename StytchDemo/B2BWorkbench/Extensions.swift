import Foundation
import StytchCore
import UIKit

enum TextFieldAlertError: Error {
    case emptyString
}

extension UIViewController {
    var organizationId: String? {
        UserDefaults.standard.string(forKey: Constants.orgIdDefaultsKey)
    }

    var memberId: String? {
        StytchB2BClient.member.getSync()?.id.rawValue
    }

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

    func presentTextFieldAlertWithTitle(
        alertTitle: String,
        buttonTitle: String = "Submit",
        completion: ((String) -> Void)? = nil
    ) {
        let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        alertController.addTextField()

        let submitAction = UIAlertAction(title: buttonTitle, style: .default) { [unowned alertController] _ in
            if let text = alertController.textFields?[0].text {
                completion?(text)
            }
        }
        alertController.addAction(submitAction)
        present(alertController, animated: true)
    }

    @MainActor
    func presentTextFieldAlertWithTitle(alertTitle: String, buttonTitle: String = "Submit") async throws -> String? {
        try await withCheckedThrowingContinuation { continuation in
            let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
            alertController.addTextField()

            let submitAction = UIAlertAction(title: buttonTitle, style: .default) { [unowned alertController] _ in
                if let text = alertController.textFields?[0].text, text.isEmpty == false {
                    continuation.resume(returning: text)
                } else {
                    continuation.resume(returning: nil)
                }
            }

            alertController.addAction(submitAction)
            present(alertController, animated: true)
        }
    }

    func presentErrorWithDescription(error: Error, description: String) {
        presentAlertWithTitle(alertTitle: "\(description) - \(error.errorInfo)")
    }

    func presentAlertAndLogMessage(description: String, object: Any) {
        if let error = object as? Error {
            presentAlertWithTitle(alertTitle: "\(description)\n\ncheck logs for more info")
            print("\(description)\n\(error.errorInfo)\n\(error)\n")
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
