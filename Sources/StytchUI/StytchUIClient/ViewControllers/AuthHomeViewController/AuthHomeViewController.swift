import StytchCore
import UIKit

final class AuthHomeViewController: BaseViewController<AuthHomeState, AuthHomeViewModel> {
    private let scrollView: UIScrollView = .init()

    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytch.authTitle", value: "Sign up or log in", comment: "")
    )

    private let separatorView: LabelSeparatorView = .orSeparator()

    private var showOrSeparator: Bool {
        guard !viewModel.state.config.oauthProviders.isEmpty else { return false }
        return viewModel.state.config.inputProductsEnabled
    }

    init(state: AuthHomeState) {
        super.init(viewModel: AuthHomeViewModel(state: state))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if navigationItem.leftBarButtonItem == nil, navigationItem.rightBarButtonItem == nil {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func configureView() {
        super.configureView()

        do {
            try viewModel.checkValidConfig()
        } catch {
            presentErrorAlert(error: error)
            return
        }

        attachStackViewToScrollView()

        stackView.addArrangedSubview(titleLabel)

        for productComponent in viewModel.productComponents {
            switch productComponent {
            case .inputProducts:
                let inputController = AuthInputViewController(state: .init(config: viewModel.state.config))
                addChild(inputController)
                stackView.addArrangedSubview(inputController.view)
            case .oAuthButtons:
                let oauthController = OAuthViewController(state: .init(config: viewModel.state.config))
                addChild(oauthController)
                stackView.addArrangedSubview(oauthController.view)
            case .divider:
                stackView.addArrangedSubview(separatorView)
            }
        }

        if StytchClient.disableSdkWatermark == false {
            setupPoweredByStytchView()
        }

        stackView.addArrangedSubview(SpacerView())

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        Task {
            try await viewModel.logRenderScreen()
        }
    }
}
