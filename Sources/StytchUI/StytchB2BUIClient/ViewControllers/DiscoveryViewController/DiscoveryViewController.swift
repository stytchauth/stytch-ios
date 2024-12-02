import AuthenticationServices
import StytchCore
import UIKit

final class DiscoveryViewController: BaseViewController<DiscoveryState, DiscoveryViewModel> {
    init(state: DiscoveryState) {
        super.init(viewModel: DiscoveryViewModel(state: state))
    }

    override func configureView() {
        super.configureView()
    }
}
