import StytchUI
import SwiftUI

@main
struct StytchUIDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(config: StytchUIDemoApp.realisticStytchUIConfig)
        }
    }

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
