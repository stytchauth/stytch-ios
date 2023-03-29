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
}
