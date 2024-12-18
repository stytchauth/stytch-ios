import StytchCore
import UIKit

final class B2BAuthHomeViewController: BaseViewController<B2BAuthHomeState, B2BAuthHomeViewModel> {
    private let scrollView: UIScrollView = .init()

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

        if let primaryRequired = B2BAuthenticationManager.primaryRequired {
            if primaryRequired.allowedAuthMethods.isEmpty == true {
                showError(configuration: viewModel.state.configuration, type: .noPrimaryAuthMethods)
            } else {
                configureView(productComponents: viewModel.products())
            }
        } else {
            StytchB2BUIClient.startLoading()
            viewModel.loadProducts { productComponents, error in
                Task { @MainActor in
                    if error != nil || productComponents.isEmpty {
                        self.showError(configuration: self.viewModel.state.configuration, type: .noOrganziationFound)
                    } else {
                        self.configureView(productComponents: productComponents)
                    }
                }
                StytchB2BUIClient.stopLoading()
            }
        }
    }

    func configureView(productComponents: [StytchB2BUIClient.ProductComponent]) {
        guard !productComponents.isEmpty else {
            showError(configuration: viewModel.state.configuration, type: .invlaidProductConfiguration)
            return
        }

        configureViewForScrollView()

        let titleLabel = UILabel.makeTitleLabel(text: titleText)
        stackView.addArrangedSubview(titleLabel)

        if B2BAuthenticationManager.primaryRequired != nil {
            let subtitleLabel = UILabel.makeSubtitleLabel(text: "Confirm your email address with one of the following")
            stackView.addArrangedSubview(subtitleLabel)
        }

        layoutProductComponents(productComponents)

        if StytchB2BClient.disableSdkWatermark == false {
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
                if let ssoActiveConnections = OrganizationManager.ssoActiveConnections {
                    let ssoViewController = B2BSSOViewController(
                        state: .init(configuration: viewModel.state.configuration),
                        delegate: self,
                        ssoActiveConnections: ssoActiveConnections
                    )
                    addChild(ssoViewController)
                    stackView.addArrangedSubview(ssoViewController.view)
                    constraints.append(ssoViewController.view.widthAnchor.constraint(equalTo: stackView.widthAnchor))
                }
            case .divider:
                stackView.addArrangedSubview(separatorView)
                constraints.append(separatorView.widthAnchor.constraint(equalTo: stackView.widthAnchor))
            }
        }

        NSLayoutConstraint.activate(constraints)
    }
}

extension B2BAuthHomeViewController {
    var titleText: String {
        if B2BAuthenticationManager.primaryRequired != nil {
            return "Verify Your Email"
        } else {
            switch viewModel.state.configuration.computedAuthFlowType {
            case .discovery:
                return "Sign up or log in"
            case .organization(slug: _):
                return "Continue to \(OrganizationManager.name ?? "...")"
            }
        }
    }
}

extension B2BAuthHomeViewController: B2BOAuthViewControllerDelegate {
    func oauthDidAuthenticatie() {
        startMFAFlowIfNeeded(configuration: viewModel.state.configuration)
    }

    func oauthDiscoveryDidAuthenticatie() {
        startDiscoveryFlowIfNeeded(configuration: viewModel.state.configuration)
    }
}

extension B2BAuthHomeViewController: B2BEmailMagicLinksViewControllerDelegate {
    func emailMagicLinkSent() {
        showEmailConfirmation(configuration: viewModel.state.configuration, type: .emailConfirmation)
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
        startMFAFlowIfNeeded(configuration: viewModel.state.configuration)
    }

    func didSendEmailMagicLink() {
        showEmailConfirmation(configuration: viewModel.state.configuration, type: .passwordResetVerify)
    }
}

extension B2BAuthHomeViewController: B2BSSOViewControllerDelegate {
    func ssoDidAuthenticatie() {
        startMFAFlowIfNeeded(configuration: viewModel.state.configuration)
    }
}
