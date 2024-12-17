import Foundation
import StytchCore
import UIKit

extension BaseViewController {
    func startMFAFlowIfNeeded(configuration: StytchB2BUIClient.Configuration) {
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

    func showEmailConfirmation(configuration: StytchB2BUIClient.Configuration, type: EmailConfirmationType) {
        Task { @MainActor in
            let emailConfirmationViewController = EmailConfirmationViewController(state: .init(configuration: configuration, type: type))
            navigationController?.pushViewController(emailConfirmationViewController, animated: true)
        }
    }

    func showError(configuration: StytchB2BUIClient.Configuration, type: ErrorScreenType) {
        Task { @MainActor in
            let emailConfirmationViewController = ErrorViewController(state: .init(configuration: configuration, type: type))
            navigationController?.pushViewController(emailConfirmationViewController, animated: true)
        }
    }
}

extension B2BMFAAuthenticateResponseDataType {
    var smsImplicitlySent: Bool {
        mfaRequired?.secondaryAuthInitiated == "sms_otp"
    }

    var memberDefaultMFAMethod: StytchB2BClient.MfaMethod? {
        member.mfaMethod
    }

    var memberEnrolledInSmsOtp: Bool {
        member.mfaPhoneNumberVerified
    }

    var memberEnrolledInTotp: Bool {
        member.totpRegistrationId.isEmpty == false
    }

    var enrolledMFAMethods: [StytchB2BClient.MfaMethod] {
        var enrolledMfaMethods: [StytchB2BClient.MfaMethod] = []

        if memberEnrolledInSmsOtp {
            enrolledMfaMethods.append(.sms)
        }

        if memberEnrolledInTotp {
            enrolledMfaMethods.append(.totp)
        }

        return enrolledMfaMethods
    }

    var isMemberDefaultMFAMethodValidForOrg: Bool {
        if let memberDefaultMFAMethod = memberDefaultMFAMethod {
            return organization.isMFAMethodAllowed(memberDefaultMFAMethod)
        } else {
            return false
        }
    }

    var defaultMFAMethod: StytchB2BClient.MfaMethod? {
        if let memberDefaultMFAMethod = memberDefaultMFAMethod, isMemberDefaultMFAMethodValidForOrg == true, enrolledMFAMethods.contains(memberDefaultMFAMethod) {
            return memberDefaultMFAMethod
        } else {
            return nil
        }
    }

    var mfaEntryMethod: StytchB2BClient.MfaMethod? {
        var entryMethod: StytchB2BClient.MfaMethod?

        if smsImplicitlySent == true {
            entryMethod = .sms
        } else if let defaultMFAMethod = defaultMFAMethod {
            entryMethod = defaultMFAMethod
        } else {
            for enrolledMFAMethod in enrolledMFAMethods {
                if organization.isMFAMethodAllowed(enrolledMFAMethod) {
                    entryMethod = enrolledMFAMethod
                    break
                }
            }
        }

        return entryMethod
    }
}
