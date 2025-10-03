import Foundation
import StytchCore
import UIKit

enum TextFieldAlertError: Error {
    case emptyString
}

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

    func presentTextFieldAlertWithTitle(
        alertTitle: String,
        buttonTitle: String = "Submit",
        cancelButtonTitle: String = "Cancel",
        completion: ((String?) -> Void)? = nil
    ) {
        let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        alertController.addTextField()

        let submitAction = UIAlertAction(title: buttonTitle, style: .default) { [unowned alertController] _ in
            if let text = alertController.textFields?[0].text {
                completion?(text)
            }
        }
        alertController.addAction(.init(title: cancelButtonTitle, style: .cancel, handler: { _ in
            completion?(nil)
        }))

        alertController.addAction(submitAction)
        present(alertController, animated: true)
    }

    @MainActor
    func presentTextFieldAlertWithTitle(
        alertTitle: String,
        buttonTitle: String = "Submit",
        cancelButtonTitle: String = "Cancel",
        keyboardType: UIKeyboardType = .default
    ) async throws -> String? {
        try await withCheckedThrowingContinuation { continuation in
            let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
            alertController.addTextField()
            alertController.textFields?[0].keyboardType = keyboardType

            let submitAction = UIAlertAction(title: buttonTitle, style: .default) { [unowned alertController] _ in
                if let text = alertController.textFields?[0].text, text.isEmpty == false {
                    continuation.resume(returning: text)
                } else {
                    continuation.resume(returning: nil)
                }
            }

            alertController.addAction(submitAction)

            alertController.addAction(.init(title: cancelButtonTitle, style: .cancel, handler: { _ in
                continuation.resume(returning: nil)
            }))

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
    static let padding: CGFloat = 16
    static let insets: UIEdgeInsets = .init(top: padding, left: padding, bottom: padding, right: padding)
    static func stytchStackView() -> UIStackView {
        let stytchStackView = UIStackView()
        stytchStackView.layoutMargins = insets
        stytchStackView.isLayoutMarginsRelativeArrangement = true
        stytchStackView.axis = .vertical
        stytchStackView.distribution = .fill
        stytchStackView.spacing = 8
        return stytchStackView
    }
}

extension UIView {
    static func spacer(height: CGFloat = 16, width: CGFloat = 0) -> UIView {
        let spacer = UIView()
        if height > 0 {
            spacer.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        if width > 0 {
            spacer.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        return spacer
    }

    static var flexibleSpacer: UIView {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return spacer
    }
}

extension UIApplication {
    // Find the topmost view controller in the app window
    static func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?.rootViewController) -> UIViewController?
    {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return tab.selectedViewController.flatMap { topViewController(base: $0) }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }

    static func showAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))

            if let topVC = UIApplication.topViewController() {
                topVC.present(alert, animated: true, completion: nil)
            }
        }
    }
}
