import Foundation
import StytchCore

// Common operations in the B2B UI used for authentication.
struct AuthenticationOperations {}

// Member and organization specific operations
extension AuthenticationOperations {
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

    static func searchMember(emailAddress: String) async throws -> StytchB2BClient.SearchManager.MemberSearchResponse? {
        guard let organizationId = OrganizationManager.organizationId else {
            throw StytchSDKError.noOrganziationId
        }

        let parameters = StytchB2BClient.SearchManager.SearchMemberParameters(emailAddress: emailAddress, organizationId: organizationId)
        let response = try await StytchB2BClient.searchManager.searchMember(searchMemberParameters: parameters)
        return response.member
    }

    static func createOrganization() async throws {
        let response = try await StytchB2BClient.discovery.createOrganization(parameters: .init())
        B2BAuthenticationManager.handlePrimaryMFAReponse(b2bMFAAuthenticateResponse: response)
    }
}

// Email magic link specific operations
extension AuthenticationOperations {
    static func sendEmailMagicLinkIfPossible(configuration: StytchB2BUIClient.Configuration, emailAddress: String) async throws {
        let emailAllowedDomains = OrganizationManager.emailAllowedDomains
        let emailJitProvisioning = OrganizationManager.emailJitProvisioning
        let emailEligibleForJITProvisioning = emailEligibleForJITProvisioning(emailAddress: emailAddress, emailAllowedDomains: emailAllowedDomains, emailJitProvisioning: emailJitProvisioning)
        if emailEligibleForJITProvisioning {
            try await sendEmailMagicLink(configuration: configuration, emailAddress: emailAddress)
        } else {
            throw StytchSDKError.emailNotEligibleForJitProvioning
        }
    }

    static func sendEmailMagicLink(configuration: StytchB2BUIClient.Configuration, emailAddress: String) async throws {
        guard let organizationId = OrganizationManager.organizationId else {
            throw StytchSDKError.noOrganziationId
        }

        let parameters = StytchB2BClient.MagicLinks.Email.Parameters(
            organizationId: Organization.ID(rawValue: organizationId),
            emailAddress: emailAddress,
            loginRedirectUrl: configuration.redirectUrl,
            signupRedirectUrl: configuration.redirectUrl,
            loginTemplateId: configuration.emailMagicLinksOptions?.loginTemplateId,
            signupTemplateId: configuration.emailMagicLinksOptions?.signupTemplateId
        )
        _ = try await StytchB2BClient.magicLinks.email.loginOrSignup(parameters: parameters)
    }

    static func sendEmailMagicLinkForAuthFlowType(configuration: StytchB2BUIClient.Configuration, emailAddress: String) async throws {
        if configuration.computedAuthFlowType == .discovery {
            let parameters = StytchB2BClient.MagicLinks.Email.DiscoveryParameters(
                emailAddress: emailAddress,
                discoveryRedirectUrl: configuration.redirectUrl
            )
            _ = try await StytchB2BClient.magicLinks.email.discoverySend(parameters: parameters)
        } else {
            try await sendEmailMagicLink(configuration: configuration, emailAddress: emailAddress)
        }
    }
}

// SMS and email OTP specific operations
extension AuthenticationOperations {
    static func sendEmailOTPForAuthFlowType(configuration: StytchB2BUIClient.Configuration, emailAddress: String) async throws {
        if configuration.computedAuthFlowType == .discovery {
            let parameters = StytchB2BClient.OTP.Email.Discovery.SendParameters(
                emailAddress: emailAddress,
                loginTemplateId: configuration.emailOtpOptions?.loginTemplateId,
                locale: nil
            )
            _ = try await StytchB2BClient.otp.email.discovery.send(parameters: parameters)
        } else {
            guard let organizationId = OrganizationManager.organizationId else {
                throw StytchSDKError.noOrganziationId
            }

            let parameters = StytchB2BClient.OTP.Email.LoginOrSignupParameters(
                organizationId: organizationId,
                emailAddress: emailAddress,
                loginTemplateId: configuration.emailOtpOptions?.loginTemplateId,
                signupTemplateId: configuration.emailOtpOptions?.signupTemplateId,
                locale: nil
            )
            _ = try await StytchB2BClient.otp.email.loginOrSignup(parameters: parameters)
        }
    }

    static func smsSendOTP(phoneNumberE164: String) async throws {
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
}

// Reset password by email specific operations
extension AuthenticationOperations {
    static func organizationResetPasswordByEmailStart(configuration: StytchB2BUIClient.Configuration, emailAddress: String) async throws {
        guard let organizationId = OrganizationManager.organizationId else {
            throw StytchSDKError.noOrganziationId
        }

        let parameters = StytchB2BClient.Passwords.ResetByEmailStartParameters(
            organizationId: Organization.ID(rawValue: organizationId),
            emailAddress: emailAddress,
            loginUrl: configuration.redirectUrl,
            resetPasswordUrl: configuration.redirectUrl,
            resetPasswordExpiration: configuration.passwordOptions?.resetPasswordExpirationMinutes,
            resetPasswordTemplateId: configuration.passwordOptions?.resetPasswordTemplateId
        )
        _ = try await StytchB2BClient.passwords.resetByEmailStart(parameters: parameters)
    }

    static func discoveryResetPasswordByEmailStart(configuration: StytchB2BUIClient.Configuration, emailAddress: String) async throws {
        let parameters = StytchB2BClient.Passwords.Discovery.ResetByEmailStartParameters(
            emailAddress: emailAddress,
            discoveryRedirectUrl: configuration.redirectUrl,
            resetPasswordRedirectUrl: configuration.redirectUrl,
            resetPasswordExpirationMinutes: configuration.sessionDurationMinutes,
            resetPasswordTemplateId: configuration.passwordOptions?.resetPasswordTemplateId
        )
        _ = try await StytchB2BClient.passwords.discovery.resetByEmailStart(parameters: parameters)
    }
}
