import StytchCore
import UIKit

final class UserSettingsViewController: UIViewController {
    private let editSettingsButton: UIButton

    override func viewDidLoad() {
        super.viewDidLoad()

        editSettingsButton.addTarget(self, action: #selector(didTapEditSettingsButton(sender:)), for: [.touchUpInside])
    }

    @objc private func didTapEditSettingsButton(sender: UIButton) {
    }
}
