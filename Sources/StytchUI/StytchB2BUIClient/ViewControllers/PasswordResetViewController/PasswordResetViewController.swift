import AuthenticationServices
import StytchCore
import UIKit

final class PasswordResetViewController: BaseViewController<PasswordResetState, PasswordResetViewModel> {
    init(state: PasswordResetState) {
        super.init(viewModel: PasswordResetViewModel(state: state))
    }

    override func configureView() {
        super.configureView()
    }
}
