import AuthenticationServices
import StytchCore
import UIKit

final class PasswordForgotViewController: BaseViewController<PasswordForgotState, PasswordForgotViewModel> {
    init(state: PasswordForgotState) {
        super.init(viewModel: PasswordForgotViewModel(state: state))
    }

    override func configureView() {
        super.configureView()
    }
}
