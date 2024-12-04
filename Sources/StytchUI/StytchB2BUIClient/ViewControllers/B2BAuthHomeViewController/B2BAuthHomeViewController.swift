import StytchCore
import UIKit

final class B2BAuthHomeViewController: BaseViewController<B2BAuthHomeState, B2BAuthHomeViewModel> {
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

    init(state: B2BAuthHomeState) {
        super.init(viewModel: B2BAuthHomeViewModel(state: state))
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
        viewModel.loadProducts { [weak self] productComponents in
            Task { @MainActor in
                self?.configureView(productComponents: productComponents)
            }
        }
    }

    func configureView(productComponents: [StytchB2BUIClient.ProductComponent]) {
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

        layoutProductComponents(productComponents)

        if StytchClient.disableSdkWatermark == false {
            stackView.addArrangedSubview(poweredByStytch)
        }

        stackView.addArrangedSubview(SpacerView())

        Task {
            try await viewModel.logRenderScreen()
        }
    }

    func layoutProductComponents(_ productComponents: [StytchB2BUIClient.ProductComponent]) {
        var constraints: [NSLayoutConstraint] = []

        for productComponent in productComponents {
            switch productComponent {
            case .emailMagicLink, .emailMagicLinkAndPasswords:
                let emailMagicLinksViewController = B2BEmailMagicLinksViewController(
                    state: .init(configuration: viewModel.state.configuration),
                    showsUsePasswordButton: productComponent == .emailMagicLinkAndPasswords,
                    delegate: self
                )
                addChild(emailMagicLinksViewController)
                stackView.addArrangedSubview(emailMagicLinksViewController.view)
                constraints.append(emailMagicLinksViewController.view.widthAnchor.constraint(equalTo: stackView.widthAnchor))
            case .password:
                let passwordsHomeViewController = B2BPasswordsHomeViewController(
                    state: .init(configuration: viewModel.state.configuration),
                    delegate: self
                )
                addChild(passwordsHomeViewController)
                stackView.addArrangedSubview(passwordsHomeViewController.view)
                constraints.append(passwordsHomeViewController.view.widthAnchor.constraint(equalTo: stackView.widthAnchor))
            case .oAuthButtons:
                let oauthController = B2BOAuthViewController(
                    state: .init(configuration: viewModel.state.configuration),
                    delegate: self
                )
                addChild(oauthController)
                stackView.addArrangedSubview(oauthController.view)
                constraints.append(oauthController.view.widthAnchor.constraint(equalTo: stackView.widthAnchor))
            case .ssoButtons:
                let ssoViewController = B2BSSOViewController(
                    state: .init(configuration: viewModel.state.configuration),
                    delegate: self
                )
                addChild(ssoViewController)
                stackView.addArrangedSubview(ssoViewController.view)
                constraints.append(ssoViewController.view.widthAnchor.constraint(equalTo: stackView.widthAnchor))
            case .divider:
                stackView.addArrangedSubview(separatorView)
                constraints.append(separatorView.widthAnchor.constraint(equalTo: stackView.widthAnchor))
            }
        }

        NSLayoutConstraint.activate(constraints)
    }

    func continueAuthenticationFlowIfNeeded() {
        Task { @MainActor in
            if viewModel.state.configuration.authFlowType == .discovery {
                let discoveryViewController = DiscoveryViewController(state: .init(configuration: viewModel.state.configuration))
                navigationController?.pushViewController(discoveryViewController, animated: true)
            } else {
                startMFAFlowIfNeeded(configuration: viewModel.state.configuration)
            }
        }
    }

    func showEmaiilConfirmation() {
        Task { @MainActor in
            let emailConfirmationViewController = EmailConfirmationViewController(state: .init(configuration: viewModel.state.configuration))
            navigationController?.pushViewController(emailConfirmationViewController, animated: true)
        }
    }
}

extension B2BAuthHomeViewController: B2BOAuthViewControllerDelegate {
    func oauthDidAuthenticatie() {
        continueAuthenticationFlowIfNeeded()
    }
}

extension B2BAuthHomeViewController: B2BEmailMagicLinksViewControllerDelegate {
    func emailMagicLinkSent() {
        showEmaiilConfirmation()
    }

    func usePasswordInstead() {
        Task { @MainActor in
            let passwordAuthenticateViewController = PasswordAuthenticateViewController(state: .init(configuration: viewModel.state.configuration))
            navigationController?.pushViewController(passwordAuthenticateViewController, animated: true)
        }
    }
}

extension B2BAuthHomeViewController: B2BPasswordsHomeViewControllerDelegate {
    func didAuthenticateWithPassword() {
        continueAuthenticationFlowIfNeeded()
    }

    func didSendEmailMagicLink() {
        showEmaiilConfirmation()
    }
}

extension B2BAuthHomeViewController: B2BSSOViewControllerDelegate {
    func ssoDidAuthenticatie() {
        continueAuthenticationFlowIfNeeded()
    }
}
