import Combine
import StytchCore
import UIKit

final class RootViewController: UIViewController {
    private var authChangeCancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()

        authChangeCancellable = StytchClient.sessions.onAuthChange
            .map { _ in StytchClient.user.getSync() }
            .sink { _ in }
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
