import AuthenticationServices
import StytchCore
import UIKit

final class EmailConfirmationViewController: BaseViewController<EmailConfirmationState, EmailConfirmationViewModel> {
    init(state: EmailConfirmationState) {
        super.init(viewModel: EmailConfirmationViewModel(state: state))
    }

    override func configureView() {
        super.configureView()
    }
}
