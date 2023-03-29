import StytchCore
import UIKit

final class UserSettingsViewController: UIViewController {
    private func attachToUser(email: String) {
        Task {
            do {
                _ = try await StytchClient.magicLinks.email.send(parameters: .init(email: email))
                showAlertToCheckEmail()
            } catch {}
        }
    }
}
