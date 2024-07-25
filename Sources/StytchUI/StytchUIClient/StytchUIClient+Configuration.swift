import Combine
import StytchCore
import SwiftUI
import UIKit

public extension StytchUIClient {
    /// Configures the Stytch UI client
    struct Configuration: Codable {
        static let empty = Configuration(products: .init())

        let navigation: Navigation?
        let products: Products
        let session: Session?
        let theme: StytchTheme

        var inputProductsEnabled: Bool {
            password != nil || magicLink != nil || otp != nil
        }

        var oauth: OAuth? {
            products.oauth
        }

        var password: Password? {
            products.password
        }

        var magicLink: MagicLink? {
            products.magicLink
        }

        var otp: OTP? {
            products.otp
        }

        public init(
            navigation: Navigation? = nil,
            products: Products,
            session: Session? = nil,
            theme: StytchTheme = StytchTheme()
        ) {
            self.navigation = navigation
            self.products = products
            self.session = session
            self.theme = theme
        }

        /// A struct defining the configuration of our sessions product. This configuration is used for all authentication flows.
        /// `sessionDuration` The length of time a new session should be valid for. This must be less than or equal to the maximum time allowed in your Stytch Dashboard
        public struct Session: Codable {
            let sessionDuration: Minutes?

            public init(sessionDuration: Minutes? = nil) {
                self.sessionDuration = sessionDuration
            }
        }

        public struct Navigation: Codable {
            let closeButtonStyle: CloseButtonStyle?

            /// - Parameter closeButtonStyle: Determines the type of close button used on the root view as well as its position.
            public init(closeButtonStyle: CloseButtonStyle? = .close(.right)) {
                self.closeButtonStyle = closeButtonStyle
            }

            public enum CloseButtonStyle: Codable {
                case cancel(BarButtonPosition = .right)
                case close(BarButtonPosition = .right)
                case done(BarButtonPosition = .right)
            }

            public enum BarButtonPosition: Codable {
                case left
                case right
            }
        }
    }
}
