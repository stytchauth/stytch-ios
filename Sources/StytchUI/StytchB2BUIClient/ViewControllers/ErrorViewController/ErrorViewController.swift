import AuthenticationServices
import StytchCore
import UIKit

final class ErrorViewController: BaseViewController<ErrorState, ErrorViewModel> {
    init(state: ErrorState) {
        super.init(viewModel: ErrorViewModel(state: state))
    }

    override func configureView() {
        super.configureView()
    }
}
