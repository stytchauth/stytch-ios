import StytchCore
import UIKit

final class UserSettingsViewController: UIViewController {
    private let editSettingsButton: UIButton

    override func viewDidLoad() {
        super.viewDidLoad()

        editSettingsButton.addTarget(self, action: #selector(didTapEditSettingsButton(sender:)), for: [.touchUpInside])
    }

    @objc private func didTapEditSettingsButton(sender: UIButton) {
        guard let session = StytchClient.sessions.session else { return }

        if session.authenticationFactors.contains(where: { $0.kind == "sms" && Date() <= $0.lastAuthenticatedAt.addingTimeInterval(60 * 5) }) {
            present(EditSettingsViewController(), animated: true)
        } else {
            Task {
                do {
                    let response = try await StytchClient.otps.send(parameters: .init(deliveryMethod: .sms(phoneNumber: user.phoneNumberE164)))
                } catch {}
            }
        }
    }
}
