import Combine
import StytchCore
import UIKit

final class RootViewController: UIViewController {
    private var authChangeCancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()

        authChangeCancellable = StytchClient.sessions.onAuthChange
            .map { _ in StytchClient.user.getSync() }
            .sink { [weak self] user in
                self?.removeChildren()
                if let user {
                    self?.addChild(AuthenticatedViewController(user: user))
                } else {
                    self?.addChild(UnauthenticatedViewController())
                }
            }
    }

    override func addChild(_ controller: UIViewController) {
        super.addChild(controller)
        view.addSubview(controller.view)
        controller.view.frame = view.bounds
    }

    private func removeChildren() {
        children.forEach { child in
            child.removeFromParent()
            child.view.removeFromSuperview()
        }
    }
}
