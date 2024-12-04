import AuthenticationServices
import StytchCore
import UIKit

final class SuccessViewController: BaseViewController<SuccessState, SuccessViewModel> {
    init(state: SuccessState) {
        super.init(viewModel: SuccessViewModel(state: state))
    }

    override func configureView() {
        super.configureView()
    }
}
