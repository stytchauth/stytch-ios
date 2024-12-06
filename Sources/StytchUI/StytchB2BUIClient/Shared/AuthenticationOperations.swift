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

    static func resetPassword(emailAddress: String, organizationId: String, redirectUrl: URL?) async throws {
        let member = try await searchMember(emailAddress: emailAddress, organizationId: organizationId)
        if member?.memberPasswordId != nil {
            let parameters = StytchB2BClient.Passwords.ResetByEmailStartParameters(
                organizationId: Organization.ID(rawValue: organizationId),
                emailAddress: emailAddress,
                resetPasswordUrl: redirectUrl,
                locale: .en
            )
            _ = try await StytchB2BClient.passwords.resetByEmailStart(parameters: parameters)
        } else {
            try await sendEmailMagicLinkIfPossible(emailAddress: emailAddress, organizationId: organizationId, redirectUrl: redirectUrl)
        }
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

    static func createTOTP() async throws -> String {
        guard let organizationId = OrganizationManager.organizationId else {
            throw StytchSDKError.noOrganziationId
        }

        guard let memberId = MemberManager.memberId else {
            throw StytchSDKError.noMemberId
        }

        let parameters = StytchB2BClient.TOTP.CreateParameters(organizationId: organizationId, memberId: memberId, expirationMinutes: 30)
        let response = try await StytchB2BClient.totp.create(parameters: parameters)
        B2BAuthenticationManager.updateTotpState(totpResponse: response.wrapped)
        return response.wrapped.secret
    }
}
