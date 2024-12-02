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

        var constraints: [NSLayoutConstraint] = []

        for productComponent in productComponents {
            switch productComponent {
            case .emailMagicLink:
                break
            case .emailMagicLinkAndPasswords:
                break
            case .password:
                break
            case .oAuthButtons:
                let oauthController = B2BOAuthViewController(state: .init(configuration: viewModel.state.configuration), delegate: self)
                addChild(oauthController)
                stackView.addArrangedSubview(oauthController.view)
                constraints.append(oauthController.view.widthAnchor.constraint(equalTo: stackView.widthAnchor))
            case .ssoButtons:
                break
            case .divider:
                stackView.addArrangedSubview(separatorView)
                constraints.append(separatorView.widthAnchor.constraint(equalTo: stackView.widthAnchor))
            }
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

extension B2BAuthHomeViewController: B2BOAuthViewControllerDelegate {
    func oauthDidAuthenticatie() {
        startMFAFlowIfNeeded(configuration: viewModel.state.configuration)
    }
}
