import SwiftUI
import StytchUI

let configuration: StytchUIDemoApp.Configuration = {
    guard let data = Bundle.main.url(forResource: "StytchUIConfiguration", withExtension: "plist").flatMap({ try? Data(contentsOf: $0) })
    else { fatalError("StytchUIConfiguration.plist should be included in the Demo App") }
    return try! PropertyListDecoder().decode(StytchUIDemoApp.Configuration.self, from: data)
}()

@main
struct StytchUIDemoApp: App {
    let uiConfig: StytchUIClient.Configuration

    var body: some Scene {
        WindowGroup {
            ContentView(config: uiConfig)
        }
    }

    init() {
        if let config = ProcessInfo.processInfo.environment["config"] {
            switch config {
            case "realistic":
                uiConfig = .realisticStytchUIConfig
            case "magiclink":
                uiConfig = .magicLinkStytchUIConfig
            default:
                uiConfig = .defaultStytchUIConfig
            }
            return
        }
        uiConfig = .magicLinkStytchUIConfig
    }
}

extension StytchUIDemoApp {
    // For simplicity, we'll mimic StytchClient.Configuration, simply to reuse that value. We'd likely have a different source of truth in a real application.
    struct Configuration: Decodable {
        let publicToken: String

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            publicToken = try container.decode(String.self, forKey: .publicToken)
        }

        private enum CodingKeys: String, CodingKey {
            case publicToken = "StytchPublicToken"
        }
    }
}

extension StytchUIClient.Configuration {
    static let defaultStytchUIConfig: StytchUIClient.Configuration = .init(
        publicToken: configuration.publicToken,
        products: .init()
    )
    static let magicLinkStytchUIConfig: StytchUIClient.Configuration = .init(
        publicToken: configuration.publicToken,
        products: .init(
            magicLink: .init()
        )
    )
    static let realisticStytchUIConfig: StytchUIClient.Configuration = .init(
        publicToken: configuration.publicToken,
        products: .init(
            oauth: .init(
                providers: [.apple, .thirdParty(.google)],
                loginRedirectUrl: .init(string: "stytch-ui://login")!,
                signupRedirectUrl: .init(string: "stytch-ui://signup")!
            ),
            password: .init(),
            magicLink: .init(),
            sms: .init()
        )
    )
}
