import Foundation
import UIKit

@objc(StytchSMSUI) public class StytchSMSUI: NSObject {

    @objc public static let shared: StytchSMSUI = StytchSMSUI()

    @objc public weak var delegate: StytchSMSUIDelegate?

    private override init() {}

    @objc public let customization = StytchUICustomization()

    @objc public func loginViewController() -> UIViewController{
        let stytchViewController = EnterPhoneNumberViewController()
        stytchViewController.delegate = delegate
        let navigationController = UINavigationController(rootViewController: stytchViewController)
        return navigationController
    }
}


@objc(StytchSMSUIDelegate) public protocol StytchSMSUIDelegate {
    @objc optional func onSuccess(_ result: StytchResult)
    @objc optional func onFailure(_ error: StytchError)
}
