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
        if let memberPhoneNumber = member?.mfaPhoneNumber {
            return memberPhoneNumber
        } else {
            return _phoneNumber
        }
    }

    static func updateMember(_ member: Member) {
        self.member = member
    }

    static func updateMemberEmailAddress(_ emailAddress: String) {
        StytchB2BUIClient.reset()
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
