import PhoneNumberKit
import StytchCore
import UIKit

final class AuthHomeViewController: BaseViewController<StytchUIClient.Configuration, Never, AppAction> {
    private let scrollView: UIScrollView = .init()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .label
        label.text = NSLocalizedString("stytch.authTitle", value: "Sign up or log in", comment: "")
        return label
    }()

    private let separatorView: LabelSeparatorView = .orSeparator

    private let poweredByStytch: UIImageView = {
        let view = UIImageView()
        view.image = ImageAsset.poweredByStytch.image
        return view
    }()

    private var showOrSeparator: Bool {
        config.oauth != nil && config.input != nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.addArrangedSubview(titleLabel)
        var constraints: [NSLayoutConstraint] = []
        if let oauthConfig = config.oauth {
            let oauthController = OAuthViewController(config: oauthConfig) { .oauth($0) }
            addChild(oauthController)
            stackView.addArrangedSubview(oauthController.view)
            constraints.append(contentsOf: [
                oauthController.view.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
                oauthController.view.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
            ])
        }
        if showOrSeparator {
            stackView.addArrangedSubview(separatorView)
            constraints.append(separatorView.widthAnchor.constraint(equalTo: stackView.widthAnchor))
        }
        if let inputConfig = config.input {
            let inputController = AuthInputViewController(config: inputConfig) { .input($0) }
            addChild(inputController)
            stackView.addArrangedSubview(inputController.view)
            constraints.append(contentsOf: [
                inputController.view.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
                inputController.view.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
            ])
        }
        if true {
            stackView.addArrangedSubview(poweredByStytch)
        }
        stackView.addArrangedSubview(SpacerView())

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        attachStackView(within: scrollView)

        scrollView.layoutMargins = .init(top: .verticalMargin, left: .horizontalMargin, bottom: .verticalMargin, right: .horizontalMargin)

        constraints.append(contentsOf: [
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        NSLayoutConstraint.activate(constraints)
    }
}
enum AppAction {
    case oauth(OAuthAction)
    case input(InputAction)
}
enum OAuthAction {
    case didTap(provider: StytchUIClient.Configuration.OAuth.Provider)
}
enum InputAction {
    case didTapCountryCode(input: PhoneNumberInput)
    case didTapContinueEmail(email: String)
    case didTapContinuePhone(phone: String)
}
struct State {
}
