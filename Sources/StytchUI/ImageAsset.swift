import StytchCore
import UIKit

enum ImageAsset {
    case oauthIcon(StytchClient.OAuth.ThirdParty.Provider)
    case poweredByStytch

    var image: UIImage? {
        let imageName: String
        switch self {
        case let .oauthIcon(provider):
            imageName = provider.rawValue.lowercased()
        case .poweredByStytch:
            imageName = "poweredbystytch"
        }
        return .init(named: imageName, in: .module, compatibleWith: nil)
    }
}
