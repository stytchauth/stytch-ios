import StytchCore
import UIKit

final class UserSettingsViewController: UIViewController {
    private let nameLabel: UILabel = .init()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = StytchClient.user.getSync() {
            nameLabel.text = user.formattedName
        }

        ...
    }
}

private extension User {
    var formattedName: String {
        [name.firstName, name.lastName]
            .compactMap { $0 }
            .joined(separator: " ")
    }
}
