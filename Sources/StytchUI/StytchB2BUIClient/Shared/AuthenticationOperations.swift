import Foundation
import StytchCore

struct AuthenticationOperations {
    static func emailEligibleForJITProvisioning(
        emailAddress: String,
        emailAllowedDomains: [String]?,
        emailJitProvisioning: StytchB2BClient.EmailJitProvisioning?
    ) -> Bool {
        guard emailJitProvisioning == StytchB2BClient.EmailJitProvisioning.restricted else {
            return false
        }

        guard let emailAllowedDomains = emailAllowedDomains, let domain = emailAddress.components(separatedBy: "@").last else {
            return false
        }

        return emailAllowedDomains.contains(domain)
    }

    static func searchMember(emailAddress: String, organizationId: String) async throws -> StytchB2BClient.SearchManager.MemberSearchResponse? {
        let parameters = StytchB2BClient.SearchManager.SearchMemberParameters(emailAddress: emailAddress, organizationId: organizationId)
        let response = try await StytchB2BClient.searchManager.searchMember(searchMemberParameters: parameters)
        return response.member
    }

    static func sendEmailMagicLinkIfPossible(emailAddress: String, organizationId: String, redirectUrl: URL?) async throws {
        let emailAllowedDomains = OrganizationManager.emailAllowedDomains
        let emailJitProvisioning = OrganizationManager.emailJitProvisioning
        let emailEligibleForJITProvisioning = emailEligibleForJITProvisioning(emailAddress: emailAddress, emailAllowedDomains: emailAllowedDomains, emailJitProvisioning: emailJitProvisioning)
        if emailEligibleForJITProvisioning {
            try await sendEmailMagicLink(emailAddress: emailAddress, organizationId: organizationId, redirectUrl: redirectUrl)
        } else {
            throw StytchSDKError.emailNotEligibleForJitProvioning
        }
    }

    static func sendEmailMagicLink(emailAddress: String, organizationId: String, redirectUrl: URL?) async throws {
        let parameters = StytchB2BClient.MagicLinks.Email.Parameters(
            organizationId: Organization.ID(rawValue: organizationId),
            emailAddress: emailAddress,
            loginRedirectUrl: redirectUrl,
            signupRedirectUrl: redirectUrl,
            locale: .en
        )
        _ = try await StytchB2BClient.magicLinks.email.loginOrSignup(parameters: parameters)
    }

    static func smsSend(phoneNumberE164: String) async throws {
        guard let organizationId = OrganizationManager.organizationId else {
            throw StytchSDKError.noOrganziationId
        }

        guard let memberId = MemberManager.memberId else {
            throw StytchSDKError.noMemberId
        }

        let parameters = StytchB2BClient.OTP.SMS.SendParameters(
            organizationId: organizationId,
            memberId: memberId,
            mfaPhoneNumber: phoneNumberE164,
            locale: nil
        )
        _ = try await StytchB2BClient.otp.sms.send(parameters: parameters)
    }

    static func createOrganization() async throws {
        let response = try await StytchB2BClient.discovery.createOrganization(parameters: .init())
        B2BAuthenticationManager.handlePrimaryMFAReponse(b2bMFAAuthenticateResponse: response)
    }
}
