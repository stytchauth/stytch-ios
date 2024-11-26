import Combine
import Foundation
import StytchCore
import SwiftUI
import UIKit

public extension StytchB2BUIClient {
    struct Configuration: Codable {
        static let empty = Configuration(publicToken: "", products: [], authFlowType: .discovery)

        let publicToken: String
        let hostUrl: URL?
        let products: [B2BProducts]
        let authFlowType: AuthFlowType
        let sessionDurationMinutes: Minutes
        let emailMagicLinksOptions: B2BEmailMagicLinksOptions?
        let passwordOptions: B2BPasswordOptions?
        let oauthProviders: [B2BOAuthProviderOptions]
        let emailOtpOptions: B2BEmailOTPOptions?
        let directLoginForSingleMembership: DirectLoginForSingleMembershipConfig?
        let disableCreateOrganization: Bool?
        let mfaProductOrder: [B2BMFAProducts]?
        let mfaProductInclude: [B2BMFAProducts]?
        let navigation: Navigation?
        let theme: StytchTheme

        var redirectUrl: String? {
            "stytchui-\(publicToken)://deeplink"
        }

        var supportsEmailMagicLinks: Bool {
            products.contains(.emailMagicLinks)
        }

        var supportsEmailOTP: Bool {
            products.contains(.emailOtp)
        }

        var supportsSSO: Bool {
            products.contains(.sso)
        }

        var supportsPasswords: Bool {
            products.contains(.passwords)
        }

        var supportsOauth: Bool {
            products.contains(.oauth) && !oauthProviders.isEmpty
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
        case passwordReset
    }

    struct B2BEmailMagicLinksOptions: Codable {
        let loginTemplateId: String?
        let signupTemplateId: String?
        let domainHint: String?

        init(
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
        let resetPasswordExpirationMinutes: Int?
        let resetPasswordTemplateId: String?

        init(
            resetPasswordExpirationMinutes: Int? = nil,
            resetPasswordTemplateId: String? = nil
        ) {
            self.resetPasswordExpirationMinutes = resetPasswordExpirationMinutes
            self.resetPasswordTemplateId = resetPasswordTemplateId
        }
    }

    struct B2BOAuthProviderOptions: Codable {
        let type: B2BOAuthProviders
        let customScopes: [String]?
        let providerParams: [String: String]?

        init(type: B2BOAuthProviders, customScopes: [String]? = nil, providerParams: [String: String]? = nil) {
            self.type = type
            self.customScopes = customScopes
            self.providerParams = providerParams
        }
    }

    enum B2BOAuthProviders: String, Codable {
        case google
        case microsoft
        case hubspot
        case slack
        case github
    }

    struct B2BEmailOTPOptions: Codable {
        let loginTemplateId: String?
        let signupTemplateId: String?

        init(loginTemplateId: String? = nil, signupTemplateId: String? = nil) {
            self.loginTemplateId = loginTemplateId
            self.signupTemplateId = signupTemplateId
        }
    }

    struct DirectLoginForSingleMembershipConfig: Codable {
        let status: Bool
        let ignoreInvites: Bool
        let ignoreJitProvisioning: Bool

        init(status: Bool, ignoreInvites: Bool, ignoreJitProvisioning: Bool) {
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
