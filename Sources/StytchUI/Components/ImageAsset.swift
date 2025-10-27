import StytchCore
import UIKit

enum ImageAsset {
    case appleOauthIcon
    case oauthIcon(StytchClient.OAuth.ThirdParty.Provider)
    case b2bOauthIcon(StytchB2BClient.OAuth.ThirdParty.Provider)
    case sso(String)
    case poweredByStytch
    case biometricsFaceID
    case biometricsTouchID

    var image: UIImage? {
        let imageName: String
        switch self {
        case .appleOauthIcon:
            imageName = "Apple"
        case let .oauthIcon(provider):
            imageName = provider.rawValue.lowercased()
        case let .b2bOauthIcon(provider):
            imageName = provider.rawValue.lowercased()
        case let .sso(provider):
            imageName = provider.lowercased()
        case .poweredByStytch:
            imageName = "poweredbystytch"
        case .biometricsFaceID:
            return UIImage(systemName: "faceid")
        case .biometricsTouchID:
            return UIImage(systemName: "touchid")
        }
        return .init(named: imageName, in: .module, compatibleWith: nil)
    }
}
