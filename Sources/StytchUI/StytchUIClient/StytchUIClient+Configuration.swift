import Combine
import StytchCore
import SwiftUI
import UIKit

public extension StytchUIClient {
    /// Configures the Stytch UI client
    struct Configuration: Codable {
        static let empty = Self(stytchClientConfiguration: .init(publicToken: "", defaultSessionDuration: 5), products: [])

        public let stytchClientConfiguration: StytchClientConfiguration
        public let products: [Products]
        public let navigation: Navigation?
        public let oauthProviders: [OAuthProvider]
        public let passwordOptions: PasswordOptions?
        public let magicLinkOptions: MagicLinkOptions?
        public let otpOptions: OTPOptions?
        public let biometricsOptions: BiometricsOptions
        public let theme: StytchTheme
        public let locale: StytchLocale

        public var redirectUrl: URL? {
            URL(string: "stytchui-\(stytchClientConfiguration.publicToken)://deeplink")
        }

        public var supportsOauth: Bool {
            products.contains(.oauth) && !oauthProviders.isEmpty
        }

        public var supportsEmailMagicLinks: Bool {
            products.contains(.emailMagicLinks)
        }

        public var supportsOTP: Bool {
            products.contains(.otp)
        }

        public var supportsPasswords: Bool {
            products.contains(.passwords)
        }

        public var supportsBiometrics: Bool {
            products.contains(.biometrics)
        }

        public var supportsBiometricsAndOAuth: Bool {
            supportsBiometrics && supportsOauth
        }

        public var supportsInputProducts: Bool {
            products.contains(.passwords) || products.contains(.emailMagicLinks) || products.contains(.otp)
        }

        /// - Parameters:
        ///   - stytchClientConfiguration: A flexible and extensible object used to configure the core `StychClient` requiring at least a public token, with optional additional settings.
        ///   - products: The products array allows you to specify the authentication methods that you would like to expose to your users.
        ///   - navigation: A configureable way to control the appearance of the dismiss button if you wish to show one.
        ///     Without a navigation configuration the UI can only be dismissed by completing authentication or manually calling StytchUIClient.dismiss().
        ///   - oauthProviders: The array of OAuth providers. If you have .oauth in your products array you must specify the list of providers.
        ///   - passwordOptions: The password options to use if you have a custom configuration.
        ///   - magicLinkOptions: The email magic link options to use if you have a custom configuration.
        ///   - otpOptions: The otp options to use if you have a custom configuration.
        ///   - biometricsOptions: The biometrics options to use if you want to configure whether biometric registration should be shown during login. If not provided, biometric registration will be shown automatically.
        ///   - theme: A configureable way to control the appearance of the UI, has default values provided
        ///   - locale: The locale is used to determine which language to use in the email. Parameter is a https://www.w3.org/International/articles/language-tags/ IETF BCP 47 language tag, e.g. "en".
        ///     Currently supported languages are English ("en"), Spanish ("es"), and Brazilian Portuguese ("pt-br"); if no value is provided, the copy defaults to English.
        public init(
            stytchClientConfiguration: StytchClientConfiguration,
            products: [Products],
            navigation: Navigation? = nil,
            oauthProviders: [OAuthProvider] = [],
            passwordOptions: PasswordOptions? = nil,
            magicLinkOptions: MagicLinkOptions? = nil,
            otpOptions: OTPOptions? = nil,
            biometricsOptions: BiometricsOptions = BiometricsOptions(showBiometricRegistrationOnLogin: true),
            theme: StytchTheme = StytchTheme(),
            locale: StytchLocale = .en
        ) {
            self.stytchClientConfiguration = stytchClientConfiguration
            self.products = products
            self.navigation = navigation
            self.oauthProviders = oauthProviders
            self.passwordOptions = passwordOptions
            self.magicLinkOptions = magicLinkOptions
            self.otpOptions = otpOptions
            self.biometricsOptions = biometricsOptions
            self.theme = theme
            self.locale = locale
        }
    }

    enum Products: String, Codable {
        case emailMagicLinks
        case oauth
        case passwords
        case otp
        case biometrics
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
        let methods: [OTPMethod]
        let expiration: Minutes?
        let loginTemplateId: String?
        let signupTemplateId: String?

        public init(
            methods: [OTPMethod],
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

    /// A struct defining the configuration of the Biometrics product.
    /// `showBiometricRegistrationOnLogin` determines whether the biometric registration screen is shown during login
    /// when biometric registration is available but not yet completed. If set to `false`, you must call
    /// `StytchClient.biometrics.register` from elsewhere in your app to handle registration.
    struct BiometricsOptions: Codable {
        let showBiometricRegistrationOnLogin: Bool

        public init(showBiometricRegistrationOnLogin: Bool) {
            self.showBiometricRegistrationOnLogin = showBiometricRegistrationOnLogin
        }
    }

    /// The OTP methods that are available
    enum OTPMethod: Codable {
        case sms
        case email
        case whatsapp
    }
}
