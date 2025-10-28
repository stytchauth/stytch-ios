import StytchCore
import UIKit

final class AuthHomeViewController: BaseViewController<AuthHomeState, AuthHomeViewModel> {
    private let scrollView: UIScrollView = .init()

    private let titleLabel: UILabel = .makeTitleLabel(
        text: LocalizationManager.stytch_b2c_home_title
    )

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
            ErrorPublisher.publishError(error)
            presentErrorAlert(error: error)
            return
        }

        attachStackViewToScrollView()

        var logoView: UIView?

        if let image = viewModel.state.config.logo?.image {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            stackView.addArrangedSubview(imageView)

            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 48),
                imageView.heightAnchor.constraint(equalToConstant: 48),
            ])

            logoView = imageView
        }

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
            case .biometrics:
                if StytchClient.biometrics.availability.isAvailableRegistered {
                    stackView.addArrangedSubview(biometricsButton)
                }
            case .divider:
                stackView.addArrangedSubview(LabelSeparatorView.orSeparator())
            }
        }

        if StytchClient.bootstrapData?.disableSdkWatermark == false {
            setupPoweredByStytchView()
        }

        stackView.addArrangedSubview(SpacerView())

        let viewsToPin = stackView.arrangedSubviews.filter { $0 !== logoView }
        NSLayoutConstraint.activate(
            viewsToPin.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        Task { try await viewModel.logRenderScreen() }
        configureCloseButton(viewModel.state.config.navigation)
    }
}

extension AuthHomeViewController {
    var biometricsButton: UIButton {
        var imageAsset = ImageAsset.biometricsFaceID
        var title = LocalizationManager.stytch_b2c_home_biometrics_continue_with_face_id

        if StytchClient.biometrics.biometryType == .touchID {
            imageAsset = ImageAsset.biometricsTouchID
            title = LocalizationManager.stytch_b2c_home_biometrics_continue_with_touch_id
        }

        let button = Button.secondary(
            image: imageAsset,
            title: title
        ) {}

        button.addTarget(self, action: #selector(authenticateBiometricsButtonTapped), for: .touchUpInside)
        return button
    }

    @objc func authenticateBiometricsButtonTapped() {
        StytchUIClient.startLoading()
        Task {
            do {
                StytchUIClient.stopLoading()
                _ = try await StytchClient.biometrics.authenticate(parameters: .init())
            } catch {
                StytchUIClient.stopLoading()
                ErrorPublisher.publishError(error)
                presentErrorAlert(error: error)
            }
        }
    }
}
