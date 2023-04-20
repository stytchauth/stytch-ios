import StytchCore
import UIKit

final class AuthenticationViewController: UIViewController {
    private func sendMagicLink(to email: String) {
        Task {
            do {
                _ = try await StytchClient.magicLinks.email.loginOrCreate(parameters: .init(email: email))
                alertUserToCheckEmail()
            } catch {}
        }
    }
}
