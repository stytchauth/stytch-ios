import StytchCore
import UIKit

enum ImageAsset {
    case oauthIcon(StytchClient.OAuth.ThirdParty.Provider)
    case b2bOauthIcon(StytchB2BClient.OAuth.ThirdParty.Provider)
    case poweredByStytch

    var image: UIImage? {
        let imageName: String
        switch self {
        case let .oauthIcon(provider):
            imageName = provider.rawValue.lowercased()
        case let .b2bOauthIcon(provider):
            imageName = provider.rawValue.lowercased()
        case .poweredByStytch:
            imageName = "poweredbystytch"
        }
        return .init(named: imageName, in: .module, compatibleWith: nil)
    }
}
