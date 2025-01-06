import Foundation
import StytchCore
import UIKit

extension UIViewController {
    var organizationId: String? {
        UserDefaults.standard.string(forKey: Constants.orgIdDefaultsKey)
    }

    var memberId: String? {
        StytchB2BClient.member.getSync()?.id.rawValue
    }
}

extension UIStackView {
    static func stytchB2BStackView() -> UIStackView {
        let view = UIStackView()
        view.layoutMargins = Constants.insets
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        view.distribution = .fillEqually
        view.spacing = 8
        return view
    }
}
