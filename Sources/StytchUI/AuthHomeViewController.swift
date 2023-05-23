import PhoneNumberKit
import StytchCore
import UIKit

final class AuthHomeViewController: BaseViewController<AuthHomeState, AuthHomeAction> {
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
        guard let oauthConfig = state.config.oauth, !oauthConfig.providers.isEmpty else { return false }
        return state.config.input != nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
        if let oauthConfig = state.config.oauth, !oauthConfig.providers.isEmpty {
            let oauthController = OAuthViewController(state: oauthConfig) { .oauth($0) }
            addChild(oauthController)
            stackView.addArrangedSubview(oauthController.view)
            constraints.append(oauthController.view.widthAnchor.constraint(equalTo: stackView.widthAnchor))
        }
        if showOrSeparator {
            stackView.addArrangedSubview(separatorView)
            constraints.append(separatorView.widthAnchor.constraint(equalTo: stackView.widthAnchor))
        }
        if let inputConfig = state.config.input {
            let inputController = AuthInputViewController(state: inputConfig) { .input($0) }
            addChild(inputController)
            stackView.addArrangedSubview(inputController.view)
            constraints.append(inputController.view.widthAnchor.constraint(equalTo: stackView.widthAnchor))
        }
        if !state.bootstrap.disableSdkWatermark {
            stackView.addArrangedSubview(poweredByStytch)
        }
        stackView.addArrangedSubview(SpacerView())

        NSLayoutConstraint.activate(constraints)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

struct AuthHomeState {
    let bootstrap: Bootstrap
    let config: StytchUIClient.Configuration
}

enum AuthHomeAction {
    case actionableInfo(AIVCAction)
    case input(AuthInputVCAction)
    case oauth(OAuthVCAction)
    case otp(OTPVCAction)
    case password(PasswordVCAction)
}
