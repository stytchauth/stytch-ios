import StytchCore

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
