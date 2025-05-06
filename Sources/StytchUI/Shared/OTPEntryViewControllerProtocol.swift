import Foundation
import UIKit

protocol OTPEntryViewControllerProtocol: UIViewController {
    var timer: Timer? { get }
    var expirationDate: Date { get }
    var expiryButton: Button { get }

    func resendCode()
    func presentCodeResetConfirmation()
}

extension OTPEntryViewControllerProtocol {
    var dateFormatter: DateComponentsFormatter {
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.minute, .second]
        return dateFormatter
    }

    func makeExpiryButton() -> Button {
        let button = Button.tertiary(
            title: ""
        ) { [weak self] in
            self?.presentCodeResetConfirmation()
        }
        button.setTitleColor(.secondaryText, for: .normal)
        button.contentHorizontalAlignment = .leading
        button.titleLabel?.numberOfLines = 0
        button.accessibilityLabel = "expiryButton"
        return button
    }

    func presentCodeResetConfirmation(recipient: String) {
        let message = LocalizationManager.stytch_otp_alert_message_new_code_will_be_sent(recipient: recipient)
        let controller = UIAlertController(
            title: LocalizationManager.stytch_otp_alert_title_resend_code,
            message: message,
            preferredStyle: .alert
        )
        controller.addAction(.init(title: LocalizationManager.stytch_otp_alert_cancel, style: .default))
        controller.addAction(.init(title: LocalizationManager.stytch_otp_alert_confirm, style: .default) { [weak self] _ in
            self?.resendCode()
        })
        controller.view.tintColor = .primaryText
        present(controller, animated: true)
    }

    func updateExpirationText() {
        if case let currentDate = Date(), expirationDate > currentDate, let dateString = dateFormatter.string(from: currentDate, to: expirationDate) {
            let attributedString = NSAttributedString(string: LocalizationManager.stytch_otp_code_expires_in(timeString: dateString), attributes: [.font: UIFont.IBMPlexSansSemiBold(size: 16)])
            expiryButton.setAttributedTitle(attributedString, for: .normal)
        } else {
            let attributedString = NSAttributedString(string: LocalizationManager.stytch_otp_code_expired, attributes: [.font: UIFont.IBMPlexSansSemiBold(size: 16)])
            expiryButton.setAttributedTitle(attributedString, for: .normal)
            timer?.invalidate()
            return
        }
    }
}
