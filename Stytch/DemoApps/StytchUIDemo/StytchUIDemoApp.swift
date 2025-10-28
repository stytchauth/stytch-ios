import StytchUI
import SwiftUI

@main
struct StytchUIDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().task {
                let configuration = StytchUIClient.Configuration(
                    stytchClientConfiguration: .init(publicToken: "public-token-live-5691c5a7-863e-4241-be93-056ee0756672"),
                    logo: CodableImage(image: UIImage(named: "logo"))
                )
                StytchUIClient.configure(configuration: configuration)
            }
        }
    }
}
