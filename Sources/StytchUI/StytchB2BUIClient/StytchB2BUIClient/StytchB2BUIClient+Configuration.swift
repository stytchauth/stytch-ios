import Combine
import Foundation
import StytchCore
import SwiftUI
import UIKit

public extension StytchB2BUIClient {
    struct Configuration: Codable {
        public static let empty = Self(stytchClientConfiguration: .init(publicToken: "", defaultSessionDuration: 5), products: [], authFlowType: .discovery)

        public let stytchClientConfiguration: StytchClientConfiguration
        public let products: [B2BProducts]
        public let authFlowType: AuthFlowType
        public let emailMagicLinksOptions: B2BEmailMagicLinksOptions?
        public let passwordOptions: B2BPasswordOptions?
        public let oauthProviders: [B2BOAuthProviderOptions]
        public let emailOtpOptions: B2BEmailOTPOptions?
        public let directLoginForSingleMembershipOptions: DirectLoginForSingleMembershipOptions?
        public let allowCreateOrganization: Bool
        public let directCreateOrganizationForNoMembership: Bool
        public let mfaProductOrder: [StytchB2BClient.MfaMethod]?
        public let mfaProductInclude: [StytchB2BClient.MfaMethod]?
        public let navigation: Navigation?
        public let theme: StytchTheme
        public let locale: StytchLocale

        public var redirectUrl: URL? {
            URL(string: "stytchui-\(stytchClientConfiguration.publicToken)://deeplink")
        }

        public var supportsEmailMagicLinks: Bool {
            products.contains(.emailMagicLinks)
        }

        public var supportsEmailOTP: Bool {
            products.contains(.emailOtp)
        }

        public var supportsSSO: Bool {
            products.contains(.sso)
        }

        public var supportsPasswords: Bool {
            products.contains(.passwords)
        }

        public var supportsOauth: Bool {
            products.contains(.oauth) && !oauthProviders.isEmpty
        }

        public var supportsEmail: Bool {
            supportsEmailMagicLinks || supportsEmailOTP
        }

        public var supportsEmailMagicLinksAndEmailOTP: Bool {
            supportsEmailMagicLinks && supportsEmailOTP
        }

        public var supportsEmailAndPasswords: Bool {
            supportsEmail && supportsPasswords
        }

        public var supportsEmailWithoutPasswords: Bool {
            supportsEmail && !supportsPasswords
        }

        public var supportsPasswordsWithoutEmail: Bool {
            !supportsEmail && supportsPasswords
        }

        public var organizationSlug: String? {
            switch computedAuthFlowType {
            case let .organization(slug: slug):
                return slug
            default:
                return nil
            }
        }

        public var createOrganizationEnabled: Bool {
            StytchB2BClient.bootstrapData?.createOrganizationEnabled ?? false
        }

        // swiftlint:disable:next identifier_name
        public var allowsDirectCreateOrganizationIfNoneExist: Bool {
            createOrganizationEnabled && directCreateOrganizationForNoMembership
        }

        public var allowsUserCreateOrganizations: Bool {
            createOrganizationEnabled && allowCreateOrganization
        }

        /// - Parameters:
        ///   - stytchClientConfiguration: A flexible and extensible object used to configure the core `StychB2BClient` requiring at least a public token, with optional additional settings.
        ///   - products: The products array allows you to specify the authentication methods that you would like to expose to your users.
        ///     The order of the products that you include here will also be the order in which they appear in the login form.
        ///   - authFlowType: The type of authentication flow you would like to begin with, either organization as specified by slug or discovery.
        ///   - emailMagicLinksOptions: The email magic link options to use if you have a custom configuration.
        ///   - passwordOptions: The password options to use if you have a custom configuration.
        ///   - oauthProviders: The array of OAuth providers. If you have .oauth in your products array you must specify the list of providers.
        ///   - emailOtpOptions: The email otp options to use if you have a custom configuration.
        ///   - directLoginForSingleMembershipOptions: An optional config that allows you to skip the discover flow and log a member in directly only if they are a member of a single organization.
        ///   - allowCreateOrganization: Whether to allow users who are not members of any organization from creating a new organization during the discovery flow.
        ///     This has no effect if the ability to create organizations from the frontend SDK is disabled in the Stytch dashboard. Defaults to `false`.
        ///   - directCreateOrganizationForNoMembership: Whether or not an organization should be created directly when a user has no memberships, invitations, or organizations they could join via JIT provisioning.
        ///     This has no effect if the ability to create organizations from the frontend SDK is disabled in the Stytch dashboard. Defaults to `false`.
        ///   - mfaProductOrder: The order to present MFA products to a member when multiple choices are available, such as during enrollment.
        ///   - mfaProductInclude: MFA products to include in the UI. If specified, the list of available products will be limited to those included. Defaults to all available products.
        ///     Note that if an organization restricts the available MFA methods, the organization's settings will take precedence.
        ///     In addition, if a member is enrolled in MFA compatible with their organization's policies, their enrolled methods will always be made available.
        ///   - navigation: A configureable way to control the appearance of the dismiss button if you wish to show one.
        ///     Without a navigation configuration the UI can only be dismissed by completing authentication or manually calling StytchB2BUIClient.dismiss().
        ///   - theme: A configureable way to control the appearance of the UI, has default values provided
        ///   - locale: The locale is used to determine which language to use in the email. Parameter is a https://www.w3.org/International/articles/language-tags/ IETF BCP 47 language tag, e.g. "en".
        ///     Currently supported languages are English ("en"), Spanish ("es"), and Brazilian Portuguese ("pt-br"); if no value is provided, the copy defaults to English.
        public init(
            stytchClientConfiguration: StytchClientConfiguration,
            products: [B2BProducts],
            authFlowType: AuthFlowType,
            emailMagicLinksOptions: B2BEmailMagicLinksOptions? = nil,
            passwordOptions: B2BPasswordOptions? = nil,
            oauthProviders: [B2BOAuthProviderOptions] = [],
            emailOtpOptions: B2BEmailOTPOptions? = nil,
            directLoginForSingleMembershipOptions: DirectLoginForSingleMembershipOptions? = nil,
            allowCreateOrganization: Bool = true,
            directCreateOrganizationForNoMembership: Bool = false,
            mfaProductOrder: [StytchB2BClient.MfaMethod]? = nil,
            mfaProductInclude: [StytchB2BClient.MfaMethod]? = nil,
            navigation: Navigation? = nil,
            theme: StytchTheme = StytchTheme(),
            locale: StytchLocale = .en
        ) {
            self.stytchClientConfiguration = stytchClientConfiguration
            self.products = products
            self.authFlowType = authFlowType
            self.emailMagicLinksOptions = emailMagicLinksOptions
            self.passwordOptions = passwordOptions
            self.oauthProviders = oauthProviders
            self.emailOtpOptions = emailOtpOptions
            self.directLoginForSingleMembershipOptions = directLoginForSingleMembershipOptions
            self.allowCreateOrganization = allowCreateOrganization
            self.directCreateOrganizationForNoMembership = directCreateOrganizationForNoMembership
            self.mfaProductOrder = mfaProductOrder
            self.mfaProductInclude = mfaProductInclude
            self.navigation = navigation
            self.theme = theme
            self.locale = locale
        }
    }

    enum B2BProducts: String, Codable {
        case emailMagicLinks
        case emailOtp
        case sso
        case passwords
        case oauth
    }

    enum AuthFlowType: Codable, Equatable {
        case discovery
        case organization(slug: String)
    }

    struct B2BEmailMagicLinksOptions: Codable {
        public let loginTemplateId: String?
        public let signupTemplateId: String?
        public let domainHint: String?

        public init(
            loginTemplateId: String? = nil,
            signupTemplateId: String? = nil,
            domainHint: String? = nil
        ) {
            self.loginTemplateId = loginTemplateId
            self.signupTemplateId = signupTemplateId
            self.domainHint = domainHint
        }
    }

    struct B2BPasswordOptions: Codable {
        public let resetPasswordExpirationMinutes: Minutes?
        public let resetPasswordTemplateId: String?
        public let verifyEmailTemplateId: String?

        public init(
            resetPasswordExpirationMinutes: Minutes? = nil,
            resetPasswordTemplateId: String? = nil,
            verifyEmailTemplateId: String? = nil
        ) {
            self.resetPasswordExpirationMinutes = resetPasswordExpirationMinutes
            self.resetPasswordTemplateId = resetPasswordTemplateId
            self.verifyEmailTemplateId = verifyEmailTemplateId
        }
    }

    struct B2BOAuthProviderOptions: Codable {
        public let provider: StytchB2BClient.OAuth.ThirdParty.Provider
        public let customScopes: [String]?
        public let providerParams: [String: String]?

        public init(provider: StytchB2BClient.OAuth.ThirdParty.Provider, customScopes: [String]? = nil, providerParams: [String: String]? = nil) {
            self.provider = provider
            self.customScopes = customScopes
            self.providerParams = providerParams
        }
    }

    struct B2BEmailOTPOptions: Codable {
        public let loginTemplateId: String?
        public let signupTemplateId: String?

        public init(loginTemplateId: String? = nil, signupTemplateId: String? = nil) {
            self.loginTemplateId = loginTemplateId
            self.signupTemplateId = signupTemplateId
        }
    }

    struct DirectLoginForSingleMembershipOptions: Codable {
        public let status: Bool
        public let ignoreInvites: Bool
        public let ignoreJitProvisioning: Bool

        public init(status: Bool, ignoreInvites: Bool, ignoreJitProvisioning: Bool) {
            self.status = status
            self.ignoreInvites = ignoreInvites
            self.ignoreJitProvisioning = ignoreJitProvisioning
        }
    }
}

// Variables in this extension are for internal logic to the B2B UI
extension StytchB2BUIClient.Configuration {
    var mfaEnrollmentMethods: [StytchB2BClient.MfaMethod] {
        var enrollmentMethods: [StytchB2BClient.MfaMethod] = []
        if OrganizationManager.allMFAMethodsAllowed == false {
            if OrganizationManager.usesSMSMFAOnly == true {
                enrollmentMethods.append(.sms)
            } else if OrganizationManager.usesTOTPMFAOnly == true {
                enrollmentMethods.append(.totp)
            }
        } else if let mfaProductInclude = mfaProductInclude {
            enrollmentMethods = mfaProductInclude
        } else {
            enrollmentMethods = [.sms, .totp]
        }
        return enrollmentMethods
    }

    var filteredOauthProviders: [StytchB2BUIClient.B2BOAuthProviderOptions] {
        switch computedAuthFlowType {
        case .discovery:
            // If we are in discovery just return what is passed in the UI config since we have no org set yet
            return oauthProviders
        case .organization:
            // If a valid primaryRequired object exists, prioritize its allowed auth methods.
            // Otherwise check the current org for if restricted mode is enabled and if so use its allowedAuthMethods.
            // If so, filter the OAuth provider options based on allowedAuthMethods, giving preference to primaryRequired.
            // Otherwise, return the array specified in the UI config.
            var allowedAuthMethods: [StytchB2BClient.AllowedAuthMethods] = []
            if let primaryRequiredAllowedAuthMethods = B2BAuthenticationManager.primaryRequired?.allowedAuthMethods {
                allowedAuthMethods = primaryRequiredAllowedAuthMethods
            } else if let organizationAllowedAuthMethods = OrganizationManager.allowedAuthMethods, OrganizationManager.authMethods == .restricted {
                allowedAuthMethods = organizationAllowedAuthMethods
            }

            if allowedAuthMethods.isEmpty == false {
                var filteredOauthProviders: [StytchB2BUIClient.B2BOAuthProviderOptions] = []
                for oauthProvider in oauthProviders where allowedAuthMethods.contains(oauthProvider.provider.allowedAuthMethodType) {
                    filteredOauthProviders.append(oauthProvider)
                }
                return filteredOauthProviders
            } else {
                return oauthProviders
            }
        }
    }

    /// `computedAuthFlowType` serves as the primary source of truth for the current authentication state.
    /// The `authFlowType` represents the initial authentication flow.
    /// For example, you might pass in an `authFlowType` of `.discovery`, but once the user selects an organization,
    /// the flow effectively transitions into an organization-based flow from the app's perspective.
    var computedAuthFlowType: StytchB2BUIClient.AuthFlowType {
        switch authFlowType {
        case .discovery:
            if let organizationSlug = OrganizationManager.slug {
                return .organization(slug: organizationSlug)
            } else {
                return .discovery
            }
        case let .organization(slug: slug):
            return .organization(slug: slug)
        }
    }
}
