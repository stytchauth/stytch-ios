import StytchUI
import SwiftUI

@main
struct StytchUIDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(configuration: StytchUIDemoApp.realisticStytchUIConfiguration)
        }
    }

    static var publicToken: String {
        "your_public_token"
    }

    static let magicLinkStytchUIConfiguration: StytchUIClient.Configuration = .init(
        publicToken: publicToken,
        products: [.emailMagicLinks]
    )

    static let passwordStytchUIConfiguration: StytchUIClient.Configuration = .init(
        publicToken: publicToken,
        products: [.passwords]
    )

    static let magicLinkPasswordStytchUIConfiguration: StytchUIClient.Configuration = .init(
        publicToken: publicToken,
        products: [.passwords, .emailMagicLinks]
    )

    static let realisticStytchUIConfiguration: StytchUIClient.Configuration = .init(
        publicToken: publicToken,
        products: [.passwords, .emailMagicLinks, .otp, .oauth],
        oauthProviders: [.apple, .thirdParty(.google)],
        otpOptions: .init(methods: [.sms])
    )
}
