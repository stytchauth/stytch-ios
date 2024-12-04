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
        public let products: [B2BProducts]
        public let authFlowType: AuthFlowType
        public let sessionDurationMinutes: Minutes
        public let emailMagicLinksOptions: B2BEmailMagicLinksOptions?
        public let passwordOptions: B2BPasswordOptions?
        public let oauthProviders: [B2BOAuthProviderOptions]
        public let emailOtpOptions: B2BEmailOTPOptions?
        public let directLoginForSingleMembership: DirectLoginForSingleMembershipConfig?
        public let disableCreateOrganization: Bool?
        public let mfaProductOrder: [B2BMFAProducts]?
        public let mfaProductInclude: [B2BMFAProducts]?
        public let navigation: Navigation?
        public let theme: StytchTheme

        public var redirectUrl: URL? {
            URL(string: "stytchui-\(publicToken)://deeplink")
        }

        public var supportsEmailMagicLinks: Bool {
            products.contains(.emailMagicLinks)
        }

        public var supportsEmailMagicLinksWithoutPasswrods: Bool {
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
            switch authFlowType {
            case let .organization(slug: slug):
                return slug
            default:
                return nil
            }
        }

        public init(
            publicToken: String,
            hostUrl: URL? = nil,
            products: [B2BProducts],
            authFlowType: AuthFlowType,
            sessionDurationMinutes: Minutes = .defaultSessionDuration,
            emailMagicLinksOptions: B2BEmailMagicLinksOptions? = nil,
            passwordOptions: B2BPasswordOptions? = nil,
            oauthProviders: [B2BOAuthProviderOptions] = [],
            emailOtpOptions: B2BEmailOTPOptions? = nil,
            directLoginForSingleMembership: DirectLoginForSingleMembershipConfig? = nil,
            disableCreateOrganization: Bool? = nil,
            mfaProductOrder: [B2BMFAProducts]? = nil,
            mfaProductInclude: [B2BMFAProducts]? = nil,
            navigation: Navigation? = nil,
            theme: StytchTheme = StytchTheme()
        ) {
            self.publicToken = publicToken
            self.hostUrl = hostUrl
            self.products = products
            self.authFlowType = authFlowType
            self.sessionDurationMinutes = sessionDurationMinutes
            self.emailMagicLinksOptions = emailMagicLinksOptions
            self.passwordOptions = passwordOptions
            self.oauthProviders = oauthProviders
            self.emailOtpOptions = emailOtpOptions
            self.directLoginForSingleMembership = directLoginForSingleMembership
            self.disableCreateOrganization = disableCreateOrganization
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

    struct DirectLoginForSingleMembershipConfig: Codable {
        public let status: Bool
        public let ignoreInvites: Bool
        public let ignoreJitProvisioning: Bool

        public init(status: Bool, ignoreInvites: Bool, ignoreJitProvisioning: Bool) {
            self.status = status
            self.ignoreInvites = ignoreInvites
            self.ignoreJitProvisioning = ignoreJitProvisioning
        }
    }

    enum B2BMFAProducts: String, Codable {
        case smsOtp
        case totp
    }
}
