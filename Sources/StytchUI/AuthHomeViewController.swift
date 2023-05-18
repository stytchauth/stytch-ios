import PhoneNumberKit
import StytchCore
import UIKit

final class AuthHomeViewController: BaseViewController<AppAction, StytchUIClient.Configuration> {
    private let scrollView: UIScrollView = .init()

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.axis = .vertical
        view.spacing = 24
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .brand
        label.text = NSLocalizedString("stytch.authTitle", value: "Sign up or log in", comment: "")
        return label
    }()

    private let separatorView = {
        let view = LabelSeparatorView()
        view.text = NSLocalizedString("stytch.orSeparator", value: "or", comment: "")
        return view
    }()

    private let poweredByStytch: UIImageView = {
        let view = UIImageView()
        view.image = ImageAsset.poweredByStytch.image
        return view
    }()

    private var showOrSeparator: Bool {
        configuration.oauth != nil && configuration.input != nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.addArrangedSubview(titleLabel)
        var constraints: [NSLayoutConstraint] = []
        if let oauthConfig = configuration.oauth {
            let oauthController = OAuthViewController(configuration: oauthConfig) { [weak self] action in
                self?.perform(action: .oauth(action))
            }
            addChild(oauthController)
            stackView.addArrangedSubview(oauthController.view)
            constraints.append(contentsOf: [
                oauthController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                oauthController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            ])
        }
        if showOrSeparator {
            stackView.addArrangedSubview(separatorView)
            constraints.append(separatorView.widthAnchor.constraint(equalTo: stackView.widthAnchor))
        }
        if let inputConfig = configuration.input {
            let inputController = AuthInputViewController(configuration: inputConfig) { [weak self] action in
                self?.perform(action: .input(action))
            }
            addChild(inputController)
            stackView.addArrangedSubview(inputController.view)
            constraints.append(contentsOf: [
                inputController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                inputController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            ])
        }
        if true {
            stackView.addArrangedSubview(poweredByStytch)
        }
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .vertical)
        stackView.addArrangedSubview(spacerView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        constraints.append(contentsOf: [
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: .horizontalMargin),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -.horizontalMargin),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: .verticalMargin),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.verticalMargin),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
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

// TODO: - make themeable
// TODO: - make customizable (what buttons go where)
import SwiftUI

struct Content_Previews: PreviewProvider {
    static var previews: some View {
        ControllerView(AuthRootViewController(configuration: .init(
            oauth: .init(providers: [.thirdParty(.google), .apple]),
            input: .magicLink(sms: true)
        )))
    }
}

struct ControllerView<UIViewControllerType: UIViewController>: UIViewControllerRepresentable {
    private let controller: UIViewControllerType

    init(_ controller: UIViewControllerType) {
        self.controller = controller
    }

    func makeUIViewController(context: Context) -> UIViewControllerType {
        controller
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

