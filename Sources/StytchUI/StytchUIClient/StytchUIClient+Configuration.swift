import Combine
import StytchCore
import SwiftUI
import UIKit

public extension StytchUIClient {
    /// Configures the Stytch UI client
    struct Configuration: Codable {
        static let empty = Configuration(publicToken: "", products: [])

        let publicToken: String
        let hostUrl: URL?
        let products: [Products]
        let navigation: Navigation?
        let sessionDurationMinutes: Minutes
        let oauthProviders: [OAuthProvider]
        let passwordOptions: PasswordOptions?
        let magicLinkOptions: MagicLinkOptions?
        let otpOptions: OTPOptions?
        let theme: StytchTheme

        var inputProductsEnabled: Bool {
            products.contains(.passwords) || products.contains(.emailMagicLinks) || products.contains(.otp)
        }

        var redirectUrl: URL? {
            URL(string: "stytchui-\(publicToken)://deeplink")
        }

        var supportsOauth: Bool {
            products.contains(.oauth) && !oauthProviders.isEmpty
        }

        var supportsEmailMagicLinks: Bool {
            products.contains(.emailMagicLinks)
        }

        var supportsOTP: Bool {
            products.contains(.otp)
        }

        var supportsPasswords: Bool {
            products.contains(.passwords)
        }

        public init(
            publicToken: String,
            hostUrl: URL? = nil,
            products: [Products],
            navigation: Navigation? = nil,
            sessionDurationMinutes: Minutes = .defaultSessionDuration,
            oauthProviders: [OAuthProvider] = [],
            passwordOptions: PasswordOptions? = nil,
            magicLinkOptions: MagicLinkOptions? = nil,
            otpOptions: OTPOptions? = nil,
            theme: StytchTheme = StytchTheme()
        ) {
            self.publicToken = publicToken
            self.hostUrl = hostUrl
            self.products = products
            self.navigation = navigation
            self.sessionDurationMinutes = sessionDurationMinutes
            self.oauthProviders = oauthProviders
            self.passwordOptions = passwordOptions
            self.magicLinkOptions = magicLinkOptions
            self.otpOptions = otpOptions
            self.theme = theme
        }
    }

    enum Products: String, Codable {
        case emailMagicLinks
        case oauth
        case passwords
        case otp
    }

    enum OAuthProvider: Codable {
        case apple
        case thirdParty(StytchClient.OAuth.ThirdParty.Provider)
    }

    /// A struct defining the configuration of the Email Magic Links product. If you do not provide a value for a property in this configuration, it will use the defaults that are configured in your Stytch Dashboard
    /// `loginExpiration` is the number of minutes that a login link is valid for
    /// `loginTemplateId` is the ID of the custom login template you have created in your Stytch Dashboard
    /// `signupExpiration` is the number of minutes that a signup link is valid for
    /// `signupTemplateId` is the ID of the custom signup template you have created in your Stytch Dashboard
    struct MagicLinkOptions: Codable {
        let loginExpiration: Minutes?
        let loginTemplateId: String?
        let signupExpiration: Minutes?
        let signupTemplateId: String?

        public init(
            loginExpiration: Minutes? = nil,
            loginTemplateId: String? = nil,
            signupExpiration: Minutes? = nil,
            signupTemplateId: String? = nil
        ) {
            self.loginExpiration = loginExpiration
            self.loginTemplateId = loginTemplateId
            self.signupExpiration = signupExpiration
            self.signupTemplateId = signupTemplateId
        }
    }

    /// A struct defining the configuration of the Passwords product. If you do not provide a value for a property in this configuration, it will use the defaults that are configured in your Stytch Dashboard
    /// `loginExpiration` is the number of minutes that a login link is valid for
    /// `resetPasswordExpiration` is the number of minutes that a reset password link is valid for
    /// `resetPasswordTemplateId` is the ID of the custom password reset template you have created in your Stytch Dashboard
    struct PasswordOptions: Codable {
        let loginExpiration: Minutes?
        let resetPasswordExpiration: Minutes?
        let resetPasswordTemplateId: String?

        public init(
            loginExpiration: Minutes? = nil,
            resetPasswordExpiration: Minutes? = nil,
            resetPasswordTemplateId: String? = nil
        ) {
            self.loginExpiration = loginExpiration
            self.resetPasswordExpiration = resetPasswordExpiration
            self.resetPasswordTemplateId = resetPasswordTemplateId
        }
    }

    /// A struct defining the configuration of the One Time Passcode (OTP) product. Leaving the optional fields `nil` will use the defaults from your Stytch Dashboard
    /// `methods` specifies the OTP methods that should be enabled
    /// `expiration` is the number of minutes that an OTP code is valid for
    /// `loginTemplateId` is the ID of the custom login template you have created in your Stytch Dashboard. This is only used for Email OTP.
    /// `signupTemplateId` is the ID of the custom signup template you have created in your Stytch Dashboard. This is only used for Email OTP.
    struct OTPOptions: Codable {
        let methods: Set<OTPMethod>
        let expiration: Minutes?
        let loginTemplateId: String?
        let signupTemplateId: String?

        public init(
            methods: Set<OTPMethod>,
            expiration: Minutes? = nil,
            loginTemplateId: String? = nil,
            signupTemplateId: String? = nil
        ) {
            self.methods = methods
            self.expiration = expiration
            self.loginTemplateId = loginTemplateId
            self.signupTemplateId = signupTemplateId
        }
    }

    /// The OTP methods that are available
    enum OTPMethod: Codable {
        case sms
        case email
        case whatsapp
    }
}
