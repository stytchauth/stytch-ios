import StytchCore
import UIKit

public enum StytchUIClient {
    public static func presentController(with config: Configuration, from controller: UIViewController) {
        StytchClient.configure(publicToken: config.publicToken)
        let authController = AuthRootViewController(config: config)
        controller.present(authController, animated: true) // TODO: add callback for when auth is completed
    }
}

public extension StytchUIClient {
    struct Configuration {
        let publicToken: String
        let oauth: OAuth?
        let input: Input?

        enum Input {
            case magicLink(sms: Bool)
            case password(sms: Bool)
            case magicLinkAndPassword(sms: Bool)
            case smsOnly
        }
        struct OAuth {
            let providers: [Provider]

            enum Provider {
                case apple
                case thirdParty(StytchClient.OAuth.ThirdParty.Provider)
            }
        }
    }
}
