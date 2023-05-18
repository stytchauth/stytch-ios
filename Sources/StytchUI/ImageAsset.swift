import UIKit

enum ImageAsset: String {
    case google
    case poweredByStytch

    var image: UIImage? {
        .init(named: rawValue.lowercased(), in: .module, compatibleWith: nil)
    }
}

