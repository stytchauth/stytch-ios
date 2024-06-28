import Foundation

public extension StytchB2BClient.Organizations.Members {
    struct UpdateParameters: Codable {
        let memberId: String
        let name: String?
        let untrustedMetadata: JSON?
        let isBreakglass: Bool?
        let mfaPhoneNumber: String?
        let mfaEnrolled: Bool?
        let roles: [String]?
        let preserveExistingSessions: Bool?
        let defaultMfaMethod: String?
        let emailAddress: String?

        /// - Parameters:
        ///   - memberId: The id of the Member.
        ///   - name: The name of the Member.
        ///   - untrustedMetadata: An arbitrary JSON object of application-specific data. These fields can be edited directly by the frontend SDK, and should not be used to store critical information.
        ///   - isBreakglass: Identifies the Member as a break glass user - someone who has permissions to authenticate into an Organization by bypassing the Organization's settings. A break glass account is typically used for emergency purposes to gain access outside of normal authentication procedures.
        ///   - mfaPhoneNumber: The Member's phone number. A Member may only have one phone number.
        ///   - mfaEnrolled: Sets whether the Member is enrolled in MFA. If true, the Member must complete an MFA step whenever they wish to log in to their Organization. If false, the Member only needs to complete an MFA step if the Organization's MFA policy is set to REQUIRED_FOR_ALL.
        ///   - roles: Roles to explicitly assign to this Member.
        ///   - preserveExistingSessions: Whether to preserve existing sessions when explicit Roles that are revoked are also implicitly assigned by SSO connection or SSO group. Defaults to false - that is, existing Member Sessions that contain SSO authentication factors with the affected SSO connection IDs will be revoked.
        ///   - defaultMfaMethod: Sets the Member's default MFA method. Valid values are 'sms_otp' and 'totp'. This value will determine 1. Which MFA method the Member is prompted to use when logging in 2. Whether An SMS will be sent automatically after completing the first leg of authentication
        ///   - emailAddress: The Member's `email_address`
        public init(
            memberId: String,
            name: String? = nil,
            untrustedMetadata: JSON? = nil,
            isBreakglass: Bool? = nil,
            mfaPhoneNumber: String? = nil,
            mfaEnrolled: Bool? = nil,
            roles: [String]? = nil,
            preserveExistingSessions: Bool? = nil,
            defaultMfaMethod: String? = nil,
            emailAddress: String? = nil
        ) {
            self.memberId = memberId
            self.name = name
            self.untrustedMetadata = untrustedMetadata
            self.isBreakglass = isBreakglass
            self.mfaPhoneNumber = mfaPhoneNumber
            self.mfaEnrolled = mfaEnrolled
            self.roles = roles
            self.preserveExistingSessions = preserveExistingSessions
            self.defaultMfaMethod = defaultMfaMethod
            self.emailAddress = emailAddress
        }
    }
}
