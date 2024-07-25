import Combine
import StytchCore
import SwiftUI
import UIKit

public extension StytchUIClient.Configuration {
    /// A struct representing the configuration options for all supported and enabled products. To enable a product, provide it's configuration options. To disable a product, leave it's configuration `nil`
    struct Products: Codable {
        let oauth: OAuth?
        let password: Password?
        let magicLink: MagicLink?
        let otp: OTP?

        public init(
            oauth: OAuth? = nil,
            password: Password? = nil,
            magicLink: MagicLink? = nil,
            otp: OTP? = nil
        ) {
            self.oauth = oauth
            self.password = password
            self.magicLink = magicLink
            self.otp = otp
        }
    }

    /// A struct defining the configuration of the OAuth product. It accepts a list of Providers as well as signup and login redirect URLs
    struct OAuth: Codable {
        let providers: [Provider]
        let loginRedirectUrl: URL
        let signupRedirectUrl: URL

        public init(providers: [Provider], loginRedirectUrl: URL, signupRedirectUrl: URL) {
            self.providers = providers
            self.loginRedirectUrl = loginRedirectUrl
            self.signupRedirectUrl = signupRedirectUrl
        }

        public enum Provider: Codable {
            case apple
            case thirdParty(StytchClient.OAuth.ThirdParty.Provider)
        }
    }

    /// A struct defining the configuration of the Email Magic Links product. If you do not provide a value for a property in this configuration, it will use the defaults that are configured in your Stytch Dashboard
    /// `loginMagicLinkUrl` is the URL served to returning users logging in
    /// `loginExpiration` is the number of minutes that a login link is valid for
    /// `loginTemplateId` is the ID of the custom login template you have created in your Stytch Dashboard
    /// `signupMagicLinkUrl` is the URL served to new users signing up
    /// `signupExpiration` is the number of minutes that a signup link is valid for
    /// `signupTemplateId` is the ID of the custom signup template you have created in your Stytch Dashboard
    struct MagicLink: Codable {
        let loginMagicLinkUrl: URL?
        let loginExpiration: Minutes?
        let loginTemplateId: String?
        let signupMagicLinkUrl: URL?
        let signupExpiration: Minutes?
        let signupTemplateId: String?

        public init(
            loginMagicLinkUrl: URL? = nil,
            loginExpiration: Minutes? = nil,
            loginTemplateId: String? = nil,
            signupMagicLinkUrl: URL? = nil,
            signupExpiration: Minutes? = nil,
            signupTemplateId: String? = nil
        ) {
            self.loginMagicLinkUrl = loginMagicLinkUrl
            self.loginExpiration = loginExpiration
            self.loginTemplateId = loginTemplateId
            self.signupMagicLinkUrl = signupMagicLinkUrl
            self.signupExpiration = signupExpiration
            self.signupTemplateId = signupTemplateId
        }
    }

    /// A struct defining the configuration of the Passwords product. If you do not provide a value for a property in this configuration, it will use the defaults that are configured in your Stytch Dashboard
    /// `loginUrl` is the URL served to returning users who are logging in
    /// `loginExpiration` is the number of minutes that a login link is valid for
    /// `resetPasswordURL` is the URL served to users who must reset their password
    /// `resetPasswordExpiration` is the number of minutes that a reset password link is valid for
    /// `resetPasswordTemplateId` is the ID of the custom password reset template you have created in your Stytch Dashboard
    struct Password: Codable {
        let loginURL: URL?
        let loginExpiration: Minutes?
        let resetPasswordURL: URL?
        let resetPasswordExpiration: Minutes?
        let resetPasswordTemplateId: String?

        public init(
            loginURL: URL? = nil,
            loginExpiration: Minutes? = nil,
            resetPasswordURL: URL? = nil,
            resetPasswordExpiration: Minutes? = nil,
            resetPasswordTemplateId: String? = nil
        ) {
            self.loginURL = loginURL
            self.loginExpiration = loginExpiration
            self.resetPasswordURL = resetPasswordURL
            self.resetPasswordExpiration = resetPasswordExpiration
            self.resetPasswordTemplateId = resetPasswordTemplateId
        }
    }

    /// A struct defining the configuration of the One Time Passcode (OTP) product. Leaving the optional fields `nil` will use the defaults from your Stytch Dashboard
    /// `methods` specifies the OTP methods that should be enabled
    /// `expiration` is the number of minutes that an OTP code is valid for
    /// `loginTemplateId` is the ID of the custom login template you have created in your Stytch Dashboard. This is only used for Email OTP.
    /// `signupTemplateId` is the ID of the custom signup template you have created in your Stytch Dashboard. This is only used for Email OTP.
    struct OTP: Codable {
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
