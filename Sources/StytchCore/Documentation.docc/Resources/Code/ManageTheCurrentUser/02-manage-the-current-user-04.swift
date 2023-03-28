import StytchCore
import UIKit

final class UserSettingsViewController: UIViewController {
    private var user: User?

    private func deleteFactor(section: Int, index: Int) {
        guard let user else { return }

        let factor: AuthenticationFactor

        // Emails are displayed in section 0 and phone numbers are displayed in section 1
        switch (section, index) {
        case (0, _):
            factor = .email(user.emails[index].id)
        case (1, _):
            factor = .phoneNumber(user.phoneNumbers[index].id)
        default:
            fatalError("We know we don't have a third section")
        }

        Task {
            do {
                let response = try await StytchClient.user.deleteFactor(factor)
                user = response.user
                updateUI()
            } catch {}
        }
    }
}
