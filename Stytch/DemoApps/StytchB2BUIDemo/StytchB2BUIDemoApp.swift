import Combine
import StytchUI
import SwiftUI

@main
struct StytchB2BUIDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(configuration: StytchB2BUIDemoApp.oauthStytchB2BUIConfig)
        }
    }

    static var publicToken: String {
        "public-token-test-b6be6a68-d178-4a2d-ac98-9579020905bf"
    }

    static let oauthStytchB2BUIConfig: StytchB2BUIClient.Configuration = .init(
        publicToken: publicToken,
        products: [.oauth],
        authFlowType: .organization(slug: "no-mfa"),
        oauthProviders: [.init(provider: .google)]
    )

    static let oauthAndEmailMagicLinksStytchB2BUIConfig: StytchB2BUIClient.Configuration = .init(
        publicToken: publicToken,
        products: [.emailMagicLinks, .oauth],
        authFlowType: .organization(slug: "no-mfa"),
        oauthProviders: [.init(provider: .google)]
    )

    static let oauthAndPasswrodsStytchB2BUIConfig: StytchB2BUIClient.Configuration = .init(
        publicToken: publicToken,
        products: [.passwords, .oauth],
        authFlowType: .organization(slug: "no-mfa"),
        oauthProviders: [.init(provider: .google)]
    )

    static let emailMagicLinksAndPasswrodsStytchB2BUIConfig: StytchB2BUIClient.Configuration = .init(
        publicToken: publicToken,
        products: [.passwords, .emailMagicLinks],
        authFlowType: .organization(slug: "no-mfa"),
        oauthProviders: [.init(provider: .google)]
    )

    static let allStytchB2BUIConfig: StytchB2BUIClient.Configuration = .init(
        publicToken: publicToken,
        products: [.emailMagicLinks, .sso, .passwords, .oauth],
        authFlowType: .organization(slug: "no-mfa"),
        oauthProviders: [.init(provider: .google)]
    )

    static let discoveryStytchB2BUIConfig: StytchB2BUIClient.Configuration = .init(
        publicToken: publicToken,
        products: [.emailMagicLinks, .sso, .passwords, .oauth],
        authFlowType: .discovery,
        oauthProviders: [.init(provider: .google)]
    )
}
