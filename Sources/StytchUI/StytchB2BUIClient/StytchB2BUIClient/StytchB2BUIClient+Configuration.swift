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
            products.contains {
                if case .emailMagicLinks = $0 {
                    return true
                }
                return false
            }
        }

        var supportsEmailOTP: Bool {
            products.contains {
                if case .emailOtp = $0 {
                    return true
                }
                return false
            }
        }

        var supportsSSO: Bool {
            products.contains {
                if case .sso = $0 {
                    return true
                }
                return false
            }
        }

        var supportsPasswords: Bool {
            products.contains {
                if case .passwords = $0 {
                    return true
                }
                return false
            }
        }

        var supportsOauth: Bool {
            products.contains {
                if case .oauth = $0 {
                    return true
                }
                return false
            }
        }

        var supportsEmailMagicLinksAndPasswords: Bool {
            supportsEmailMagicLinks && supportsPasswords
        }

        public init(
            publicToken: String,
            hostUrl: URL? = nil,
            products: [B2BProducts],
            authFlowType: AuthFlowType,
            sessionDurationMinutes: Minutes = .defaultSessionDuration,
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
            self.directLoginForSingleMembership = directLoginForSingleMembership
            self.disableCreateOrganization = disableCreateOrganization
            self.mfaProductOrder = mfaProductOrder
            self.mfaProductInclude = mfaProductInclude
            self.navigation = navigation
            self.theme = theme
        }
    }

    enum B2BProducts: Codable, Equatable {
        case emailMagicLinks(emailMagicLinksOptions: B2BEmailMagicLinksOptions?)
        case emailOtp(emailOtpOptions: B2BEmailOTPOptions?)
        case sso
        case passwords(passwordOptions: B2BPasswordOptions?)
        case oauth(oauthProviders: [B2BOAuthProviderOptions])

        public static func == (lhs: B2BProducts, rhs: B2BProducts) -> Bool {
            switch (lhs, rhs) {
            case (.emailMagicLinks, .emailMagicLinks):
                return true
            case (.emailOtp, .emailOtp):
                return true
            case (.sso, .sso):
                return true
            case (.passwords, .passwords):
                return true
            case (.oauth, .oauth):
                return true
            default:
                return false
            }
        }
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
