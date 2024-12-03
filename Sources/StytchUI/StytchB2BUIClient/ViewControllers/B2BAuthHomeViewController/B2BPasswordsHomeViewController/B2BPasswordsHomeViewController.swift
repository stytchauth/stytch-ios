import AuthenticationServices
import StytchCore
import UIKit

final class B2BPasswordsHomeViewController: BaseViewController<B2BPasswordsHomeState, B2BPasswordsHomeViewModel> {
    init(state: B2BPasswordsHomeState) {
        super.init(viewModel: B2BPasswordsHomeViewModel(state: state))
    }

    override func configureView() {
        super.configureView()
    }
}
