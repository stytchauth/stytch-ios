import Combine
import StytchCore
import UIKit

final class RootViewController: UIViewController {
    private var authChangeCancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()

        authChangeCancellable = StytchClient.sessions.onAuthChange
            .sink { _ in }
    }
}
