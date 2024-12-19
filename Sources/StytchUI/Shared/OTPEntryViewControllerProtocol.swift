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

    func expiryAttributedText(initialSegment: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: initialSegment + NSLocalizedString("stytch.otpDidntGetIt", value: " Didn't get it?", comment: ""), attributes: [.font: UIFont.IBMPlexSansRegular(size: 16)])
        let appendedAttributedString = NSAttributedString(string: NSLocalizedString("stytch.otpResendIt", value: " Resend it.", comment: ""), attributes: [.font: UIFont.IBMPlexSansSemiBold(size: 16)])
        attributedString.append(appendedAttributedString)
        return attributedString
    }

    func presentCodeResetConfirmation(message: String?) {
        let controller = UIAlertController(
            title: NSLocalizedString("stytch.otpResendCode", value: "Resend code", comment: ""),
            message: message,
            preferredStyle: .alert
        )
        controller.addAction(.init(title: NSLocalizedString("stytch.otpCancel", value: "Cancel", comment: ""), style: .default))
        controller.addAction(.init(title: NSLocalizedString("stytch.otpConfirm", value: "Send code", comment: ""), style: .default) { [weak self] _ in
            self?.resendCode()
        })
        controller.view.tintColor = .primaryText
        present(controller, animated: true)
    }

    func updateExpirationText() {
        if case let currentDate = Date(), expirationDate > currentDate, let dateString = dateFormatter.string(from: currentDate, to: expirationDate) {
            expiryButton.setAttributedTitle(
                expiryAttributedText(initialSegment: .localizedStringWithFormat(NSLocalizedString("stytch.otpCodeExpiresIn", value: "Your code expires in %@.", comment: ""), dateString)),
                for: .normal
            )
        } else {
            expiryButton.setAttributedTitle(
                expiryAttributedText(initialSegment: NSLocalizedString("stytch.otpCodeExpired", value: "Your code has expired.", comment: "")),
                for: .normal
            )
            timer?.invalidate()
            return
        }
    }
}
