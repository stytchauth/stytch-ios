import UIKit

enum ImageAsset: String {
    // FIXME: add image assets for all third-party providers
    case google
    case poweredByStytch

    var image: UIImage? {
        .init(named: rawValue.lowercased(), in: .module, compatibleWith: nil)
    }
}

