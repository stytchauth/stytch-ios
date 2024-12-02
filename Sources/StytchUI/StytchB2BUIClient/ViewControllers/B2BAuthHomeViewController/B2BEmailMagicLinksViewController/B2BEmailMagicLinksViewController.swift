import AuthenticationServices
import StytchCore
import UIKit

final class B2BEmailMagicLinksViewController: BaseViewController<B2BEmailMagicLinksState, B2BEmailMagicLinksViewModel> {
    init(state: B2BEmailMagicLinksState) {
        super.init(viewModel: B2BEmailMagicLinksViewModel(state: state))
    }

    override func configureView() {
        super.configureView()
    }
}
