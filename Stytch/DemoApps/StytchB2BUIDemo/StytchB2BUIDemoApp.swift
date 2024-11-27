import Combine
import StytchUI
import SwiftUI

@main
struct StytchB2BUIDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(configuration: StytchB2BUIDemoApp.realisticStytchUIConfig)
        }
    }

    static let realisticStytchUIConfig: StytchB2BUIClient.Configuration = .init(
        publicToken: "public-token",
        products: [.emailMagicLinks(emailMagicLinksOptions: nil)],
        authFlowType: .organization(slug: "1234")
    )
}
