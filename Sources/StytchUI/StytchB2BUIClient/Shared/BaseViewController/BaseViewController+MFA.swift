import StytchCore
import UIKit

extension BaseViewController {
    func startMFAFlowIfNeeded(configuration: StytchB2BUIClient.Configuration) {
        guard B2BAuthenticationManager.isAuthenticated == false else {
            return
        }

        Task { @MainActor in
            var viewController: UIViewController?

            let b2bMFAAuthenticateResponse = B2BAuthenticationManager.b2bMFAAuthenticateResponse

            if b2bMFAAuthenticateResponse?.primaryRequired != nil {
                viewController = B2BAuthHomeViewController(state: .init(configuration: configuration))
            } else if let entryMethod = b2bMFAAuthenticateResponse?.mfaEntryMethod {
                switch entryMethod {
                case .sms:
                    viewController = SMSOTPEntryViewController(state: .init(configuration: configuration, didSendCode: b2bMFAAuthenticateResponse?.smsImplicitlySent ?? false))
                case .totp:
                    viewController = TOTPEntryViewController(state: .init(configuration: configuration))
                }
            } else {
                let enrollmentMethods = configuration.mfaEnrollmentMethods
                if enrollmentMethods.count == 1, enrollmentMethods.contains(.sms) {
                    viewController = SMSOTPEnrollmentViewController(state: .init(configuration: configuration))
                }
                if enrollmentMethods.count == 1, enrollmentMethods.contains(.totp) {
                    viewController = TOTPEnrollmentViewController(state: .init(configuration: configuration))
                } else {
                    viewController = MFAEnrollmentSelectionViewController(state: .init(configuration: configuration))
                }
            }

            if let viewController {
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}
