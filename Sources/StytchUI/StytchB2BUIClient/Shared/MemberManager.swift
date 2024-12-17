import PhoneNumberKit
import StytchCore

struct MemberManager {
    static var member: Member?
    fileprivate static var _emailAddress: String?
    fileprivate static var _phoneNumber: String?

    static var memberId: String? {
        member?.id.rawValue
    }

    static var emailAddress: String? {
        if let memberEmailAddress = member?.emailAddress {
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
        let phoneNumberKit = PhoneNumberKit()
        guard let memberPhoneNumber = phoneNumber else {
            return ""
        }

        guard let parsedPhoneNumber = try? phoneNumberKit.parse(memberPhoneNumber) else {
            return memberPhoneNumber
        }

        let formattedPhoneNumber = phoneNumberKit.format(parsedPhoneNumber, toType: .international)
        return formattedPhoneNumber
    }

    static func updateMember(_ member: Member) {
        self.member = member
    }

    static func updateMemberEmailAddress(_ emailAddress: String) {
        B2BAuthenticationManager.reset()
        DiscoveryManager.reset()
        reset()
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
