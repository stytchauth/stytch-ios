import Foundation
@preconcurrency import SwiftyJSON

public extension StytchB2BClient.Organizations.Members {
    struct CreateParameters: Codable, Sendable {
        let emailAddress: String
        let name: String?
        let untrustedMetadata: JSON?
        let createMemberAsPending: Bool?
        let isBreakglass: Bool?
        let mfaPhoneNumber: String?
        let mfaEnrolled: Bool?
        let roles: [String]?

        /// - Parameters:
        ///   - emailAddress: the Member's `email_address`
        ///   - name: name The name of the Member.
        ///   - untrustedMetadata: An arbitrary JSON object of application-specific data. These fields can be edited directly by the frontend SDK, and should not be used to store critical information.
        ///   - createMemberAsPending: Flag for whether or not to save a Member as pending or active in Stytch. It defaults to false. If true, new Members will be created with status pending in Stytch's backend. Their status will remain pending and they will continue to receive signup email templates for every Email Magic Link until that Member authenticates and becomes active. If false, new Members will be created with status active.
        ///   - isBreakglass: Identifies the Member as a break glass user - someone who has permissions to authenticate into an Organization by bypassing the Organization's settings. A break glass account is typically used for emergency purposes to gain access outside of normal authentication procedures.
        ///   - mfaPhoneNumber: The Member's phone number. A Member may only have one phone number.
        ///   - mfaEnrolled: Sets whether the Member is enrolled in MFA. If true, the Member must complete an MFA step whenever they wish to log in to their Organization. If false, the Member only needs to complete an MFA step if the Organization's MFA policy is set to REQUIRED_FOR_ALL.
        ///   - roles: Roles to explicitly assign to this Member.
        public init(
            emailAddress: String,
            name: String? = nil,
            untrustedMetadata: JSON? = nil,
            createMemberAsPending: Bool? = nil,
            isBreakglass: Bool? = nil,
            mfaPhoneNumber: String? = nil,
            mfaEnrolled: Bool? = nil,
            roles: [String]? = nil
        ) {
            self.emailAddress = emailAddress
            self.name = name
            self.untrustedMetadata = untrustedMetadata
            self.createMemberAsPending = createMemberAsPending
            self.isBreakglass = isBreakglass
            self.mfaPhoneNumber = mfaPhoneNumber
            self.mfaEnrolled = mfaEnrolled
            self.roles = roles
        }
    }
}
