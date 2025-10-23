import PhoneNumberKit
import StytchCore

struct MemberManager {
    private(set) static var member: Member?
    // swiftlint:disable:next identifier_name
    fileprivate private(set) static var _emailAddress: String?
    // swiftlint:disable:next identifier_name
    fileprivate private(set) static var _phoneNumber: String?

    static var memberId: String? {
        member?.id.rawValue
    }

    static var emailAddress: String? {
        if let memberEmailAddress = member?.emailAddress, memberEmailAddress.isEmpty == false {
            return memberEmailAddress
        } else {
            return _emailAddress
        }
    }

    static var phoneNumber: String? {
        if let memberPhoneNumber = member?.mfaPhoneNumber, memberPhoneNumber.isEmpty == false {
            return memberPhoneNumber
        } else {
            return _phoneNumber
        }
    }

    static var formattedPhoneNumber: String {
        let phoneNumberUtility = PhoneNumberUtility()
        guard let memberPhoneNumber = phoneNumber else {
            return ""
        }

        guard let parsedPhoneNumber = try? phoneNumberUtility.parse(memberPhoneNumber) else {
            return memberPhoneNumber
        }

        let formattedPhoneNumber = phoneNumberUtility.format(parsedPhoneNumber, toType: .international)
        return formattedPhoneNumber
    }

    static func updateMember(_ member: Member) {
        self.member = member
    }

    static func updateMemberEmailAddress(_ emailAddress: String) {
        // If updating the member email and not in the primary required state,
        // reset all state except the organization. This assumes the login flow is being initiated for a new user.
        // The primary required state is for verifying the email, not for starting a new user's flow.
        if B2BAuthenticationManager.primaryRequired == nil {
            B2BAuthenticationManager.reset()
            DiscoveryManager.reset()
            reset()
        }

        _emailAddress = emailAddress
    }

    static func updateMemberPhoneNumber(_ phoneNumber: String) {
        _phoneNumber = phoneNumber
    }

    static func reset() {
        member = nil
        _emailAddress = nil
        _phoneNumber = nil
    }
}
