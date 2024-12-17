import Combine
import Foundation
import StytchCore
import SwiftUI
import UIKit

public extension StytchB2BUIClient {
    struct Configuration: Codable {
        static let empty = Configuration(publicToken: "", products: [], authFlowType: .discovery)

        public let publicToken: String
        public let hostUrl: URL?
        public let dfppaDomain: String?
        public let products: [B2BProducts]
        public let authFlowType: AuthFlowType
        public let sessionDurationMinutes: Minutes
        public let emailMagicLinksOptions: B2BEmailMagicLinksOptions?
        public let passwordOptions: B2BPasswordOptions?
        public let oauthProviders: [B2BOAuthProviderOptions]
        public let emailOtpOptions: B2BEmailOTPOptions?
        public let directLoginForSingleMembershipOptions: DirectLoginForSingleMembershipOptions?
        public let allowCreateOrganization: Bool
        public let mfaProductOrder: [StytchB2BClient.MfaMethod]?
        public let mfaProductInclude: [StytchB2BClient.MfaMethod]?
        public let navigation: Navigation?
        public let theme: StytchTheme

        public var redirectUrl: URL? {
            URL(string: "stytchui-\(publicToken)://deeplink")
        }

        public var supportsEmailMagicLinks: Bool {
            products.contains(.emailMagicLinks)
        }

        public var supportsEmailMagicLinksWithoutPasswords: Bool {
            supportsEmailMagicLinks && !supportsPasswords
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

        public var supportsPasswordsWithoutEmailMagiclinks: Bool {
            !supportsEmailMagicLinks && supportsPasswords
        }

        public var supportsOauth: Bool {
            products.contains(.oauth) && !oauthProviders.isEmpty
        }

        public var supportsEmailMagicLinksAndPasswords: Bool {
            supportsEmailMagicLinks && supportsPasswords
        }

        public var organizationSlug: String? {
            switch computedAuthFlowType {
            case let .organization(slug: slug):
                return slug
            default:
                return nil
            }
        }

        public init(
            publicToken: String,
            hostUrl: URL? = nil,
            dfppaDomain: String? = nil,
            products: [B2BProducts],
            authFlowType: AuthFlowType,
            sessionDurationMinutes: Minutes = .defaultSessionDuration,
            emailMagicLinksOptions: B2BEmailMagicLinksOptions? = nil,
            passwordOptions: B2BPasswordOptions? = nil,
            oauthProviders: [B2BOAuthProviderOptions] = [],
            emailOtpOptions: B2BEmailOTPOptions? = nil,
            directLoginForSingleMembershipOptions: DirectLoginForSingleMembershipOptions? = nil,
            allowCreateOrganization: Bool = true,
            mfaProductOrder: [StytchB2BClient.MfaMethod]? = nil,
            mfaProductInclude: [StytchB2BClient.MfaMethod]? = nil,
            navigation: Navigation? = nil,
            theme: StytchTheme = StytchTheme()
        ) {
            self.publicToken = publicToken
            self.hostUrl = hostUrl
            self.dfppaDomain = dfppaDomain
            self.products = products
            self.authFlowType = authFlowType
            self.sessionDurationMinutes = sessionDurationMinutes
            self.emailMagicLinksOptions = emailMagicLinksOptions
            self.passwordOptions = passwordOptions
            self.oauthProviders = oauthProviders
            self.emailOtpOptions = emailOtpOptions
            self.directLoginForSingleMembershipOptions = directLoginForSingleMembershipOptions
            self.allowCreateOrganization = allowCreateOrganization
            self.mfaProductOrder = mfaProductOrder
            self.mfaProductInclude = mfaProductInclude
            self.navigation = navigation
            self.theme = theme
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
        public let resetPasswordExpirationMinutes: Int?
        public let resetPasswordTemplateId: String?

        public init(
            resetPasswordExpirationMinutes: Int? = nil,
            resetPasswordTemplateId: String? = nil
        ) {
            self.resetPasswordExpirationMinutes = resetPasswordExpirationMinutes
            self.resetPasswordTemplateId = resetPasswordTemplateId
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
        case .organization(slug: _):
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
                for oauthProvider in oauthProviders {
                    if allowedAuthMethods.contains(oauthProvider.provider.allowedAuthMethodType) {
                        filteredOauthProviders.append(oauthProvider)
                    }
                }
                return filteredOauthProviders
            } else {
                return oauthProviders
            }
        }
    }

    var computedAuthFlowType: StytchB2BUIClient.AuthFlowType {
        switch authFlowType {
        case .discovery:
            if B2BAuthenticationManager.primaryRequired != nil, let organizationSlug = OrganizationManager.organizationSlug {
                return .organization(slug: organizationSlug)
            } else {
                return .discovery
            }
        case let .organization(slug: slug):
            return .organization(slug: slug)
        }
    }
}
