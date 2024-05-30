import StytchCore
import UIKit

final class AppViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        viewControllers = [RootViewController()]
    }
}
