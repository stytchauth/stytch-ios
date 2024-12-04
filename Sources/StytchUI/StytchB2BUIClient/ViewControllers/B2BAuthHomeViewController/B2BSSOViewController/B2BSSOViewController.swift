import AuthenticationServices
import StytchCore
import UIKit

protocol B2BSSOViewControllerDelegate: AnyObject {
    func ssoDidAuthenticatie()
}

final class B2BSSOViewController: BaseViewController<SSOState, SSOViewModel> {
    weak var delegate: B2BSSOViewControllerDelegate?

    init(state: SSOState, delegate: B2BSSOViewControllerDelegate?) {
        super.init(viewModel: SSOViewModel(state: state))
        self.delegate = delegate
    }

    override func configureView() {
        super.configureView()
    }
}
