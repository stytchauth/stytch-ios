import StytchCore
import UIKit

final class B2BAuthHomeViewController: BaseViewController<B2BAuthHomeState, B2BAuthHomeViewModel> {
    private let scrollView: UIScrollView = .init()

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

        configureCloseButton(viewModel.state.configuration.navigation)
    }

    func configureView(productComponents: [StytchB2BUIClient.ProductComponent]) {
        guard !productComponents.isEmpty else {
            showError(configuration: viewModel.state.configuration, type: .invlaidProductConfiguration)
            return
        }

        attachStackViewToScrollView()

        let titleLabel = UILabel.makeTitleLabel(text: titleText)
        stackView.addArrangedSubview(titleLabel)

        if B2BAuthenticationManager.primaryRequired != nil {
            let subtitleLabel = UILabel.makeSubtitleLabel(text: LocalizationManager.stytch_b2b_home_confirm_email)
            stackView.addArrangedSubview(subtitleLabel)
        }

        layoutProductComponents(productComponents)

        if StytchB2BClient.bootstrapData?.disableSdkWatermark == false {
            setupPoweredByStytchView()
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
            case .email, .emailAndPasswords:
                let emailMagicLinksViewController = B2BEmailViewController(
                    state: .init(configuration: viewModel.state.configuration),
                    showsUsePasswordButton: productComponent == .emailAndPasswords,
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
                    delegate: self,
                    ssoActiveConnections: OrganizationManager.ssoActiveConnections ?? []
                )
                addChild(ssoViewController)
                stackView.addArrangedSubview(ssoViewController.view)
                constraints.append(ssoViewController.view.widthAnchor.constraint(equalTo: stackView.widthAnchor))
            case .divider:
                let separatorView = LabelSeparatorView.orSeparator()
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
            return LocalizationManager.stytch_b2b_home_verify_email
        } else {
            switch viewModel.state.configuration.computedAuthFlowType {
            case .discovery:
                return LocalizationManager.stytch_b2b_home_sign_up_or_log_in
            case .organization:
                return LocalizationManager.stytch_b2b_home_continue_to_organization(organization: OrganizationManager.name ?? "...")
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

extension B2BAuthHomeViewController: B2BEmailViewControllerDelegate {
    func emailOTPSent() {
        Task { @MainActor in
            let emailOTPEntryViewController = EmailOTPEntryViewController(state: .init(configuration: viewModel.state.configuration, didSendCode: true))
            navigationController?.pushViewController(emailOTPEntryViewController, animated: true)
        }
    }

    func emailMagicLinkSent() {
        showEmailConfirmation(configuration: viewModel.state.configuration, type: .emailConfirmation)
    }

    func showEmailMethodSelection() {
        Task { @MainActor in
            let emailMethodSelectionViewController = EmailMethodSelectionViewController(state: .init(configuration: viewModel.state.configuration))
            navigationController?.pushViewController(emailMethodSelectionViewController, animated: true)
        }
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

    func didDiscoveryAuthenticateWithPassword() {
        startDiscoveryFlowIfNeeded(configuration: viewModel.state.configuration)
    }

    func didSendEmailMagicLink() {
        showEmailConfirmation(configuration: viewModel.state.configuration, type: .passwordResetVerify)
    }
}

extension B2BAuthHomeViewController: B2BSSOViewControllerDelegate {
    func didTapSSODiscovery() {
        Task { @MainActor in
            let ssoDiscoveryEmailViewController = SSODiscoveryEmailViewController(state: .init(configuration: viewModel.state.configuration))
            navigationController?.pushViewController(ssoDiscoveryEmailViewController, animated: true)
        }
    }

    func ssoDidAuthenticatie() {
        startMFAFlowIfNeeded(configuration: viewModel.state.configuration)
    }
}
