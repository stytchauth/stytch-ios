import StytchCore
import UIKit

final class AuthHomeViewController: BaseViewController<AuthHomeState, AuthHomeViewModel> {
    private let scrollView: UIScrollView = .init()

    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytch.authTitle", value: "Sign up or log in", comment: "")
    )

    private let separatorView: LabelSeparatorView = .orSeparator()

    private lazy var poweredByStytch: UIImageView = {
        let view = UIImageView()
        view.image = ImageAsset.poweredByStytch.image
        view.accessibilityLabel = "poweredByStytch"
        return view
    }()

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
        var constraints: [NSLayoutConstraint] = []
        if !viewModel.state.config.oauthProviders.isEmpty {
            let oauthController = OAuthViewController(state: .init(config: viewModel.state.config))
            addChild(oauthController)
            stackView.addArrangedSubview(oauthController.view)
            constraints.append(oauthController.view.widthAnchor.constraint(equalTo: stackView.widthAnchor))
        }
        if showOrSeparator {
            stackView.addArrangedSubview(separatorView)
            constraints.append(separatorView.widthAnchor.constraint(equalTo: stackView.widthAnchor))
        }
        if viewModel.state.config.inputProductsEnabled {
            let inputController = AuthInputViewController(state: .init(config: viewModel.state.config))
            addChild(inputController)
            stackView.addArrangedSubview(inputController.view)
            constraints.append(inputController.view.widthAnchor.constraint(equalTo: stackView.widthAnchor))
        }
        if StytchClient.disableSdkWatermark == false {
            stackView.addArrangedSubview(poweredByStytch)
        }
        stackView.addArrangedSubview(SpacerView())

        NSLayoutConstraint.activate(constraints)

        Task {
            try await viewModel.logRenderScreen()
        }
    }
}
