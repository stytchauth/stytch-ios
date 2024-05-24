import StytchUI
import SwiftUI

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
            case "password":
                uiConfig = .passwordStytchUIConfig
            case "magiclinkpassword":
                uiConfig = .magicLinkPasswordStytchUIConfig
            case "invalidemail":
                uiConfig = .invalidEmailStytchUIConfig
            default:
                uiConfig = .defaultStytchUIConfig
            }
            return
        }
        uiConfig = .realisticStytchUIConfig
    }
}

extension StytchUIClient.Configuration {
    static let defaultStytchUIConfig: StytchUIClient.Configuration = .init(
        products: .init()
    )
    static let magicLinkStytchUIConfig: StytchUIClient.Configuration = .init(
        products: .init(
            magicLink: .init()
        )
    )
    static let passwordStytchUIConfig: StytchUIClient.Configuration = .init(
        products: .init(
            password: .init()
        )
    )
    static let magicLinkPasswordStytchUIConfig: StytchUIClient.Configuration = .init(
        products: .init(
            password: .init(),
            magicLink: .init()
        )
    )
    static let realisticStytchUIConfig: StytchUIClient.Configuration = .init(
        products: .init(
            oauth: .init(
                providers: [.apple, .thirdParty(.google)],
                loginRedirectUrl: .init(string: "stytch-ui://login")!,
                signupRedirectUrl: .init(string: "stytch-ui://signup")!
            ),
            password: .init(),
            magicLink: .init(),
            otp: .init(methods: [.sms])
        )
    )
    static let invalidEmailStytchUIConfig: StytchUIClient.Configuration = .init(
        products: .init(
            magicLink: .init(),
            otp: .init(methods: [.email])
        )
    )
}
