import UIKit

final class AuthHomeViewModel: BaseViewModel<AuthHomeState, AuthHomeAction> {
    // TODO: Add view model logic
}

final class AuthHomeViewController: BaseViewController<AuthHomeState, AuthHomeAction, AuthHomeViewModel> {
    private let scrollView: UIScrollView = .init()

    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytch.authTitle", value: "Sign up or log in", comment: "")
    )

    private let separatorView: LabelSeparatorView = .orSeparator()

    private lazy var poweredByStytch: UIImageView = {
        let view = UIImageView()
        view.image = ImageAsset.poweredByStytch.image
        return view
    }()

    private var showOrSeparator: Bool {
        guard let oauth = viewModel.state.config.oauth, !oauth.providers.isEmpty else { return false }
        return viewModel.state.config.inputProductsEnabled
    }

    override func configureView() {
        super.configureView()

        view.addSubview(scrollView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.clipsToBounds = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        ])

        attachStackView(within: scrollView, usingLayoutMarginsGuide: false)

        stackView.addArrangedSubview(titleLabel)
        var constraints: [NSLayoutConstraint] = []
        if let config = viewModel.state.config.oauth, !config.providers.isEmpty {
            let oauthController = OAuthViewController(state: .init(oauth: config))
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
        if !viewModel.state.bootstrap.disableSdkWatermark {
            stackView.addArrangedSubview(poweredByStytch)
        }
        stackView.addArrangedSubview(SpacerView())

        NSLayoutConstraint.activate(constraints)
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
}

struct AuthHomeState: BaseState {
    let bootstrap: Bootstrap
    let config: StytchUIClient.Configuration
}

enum AuthHomeAction: BaseAction {
    case actionableInfo(ActionableInfoAction)
    case input(AuthInputAction)
    case oauth(OAuthAction)
    case otp(OTPAction)
    case password(PasswordAction)
}
