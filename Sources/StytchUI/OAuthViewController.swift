import AuthenticationServices
import StytchCore
import UIKit

final class OAuthViewController: BaseViewController<StytchUIClient.Configuration.OAuth, OAuthVCAction> {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.layoutMargins = .zero

        state.providers.enumerated().forEach { index, provider in
            let button = Self.makeOauthButton(provider: provider)
            button.tag = index
            button.addTarget(self, action: #selector(didTapOAuthButton(sender:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
    }

    @objc private func didTapOAuthButton(sender: UIControl) {
        guard let (_, provider) = state.providers.enumerated().first(where: { $0.offset == sender.tag }) else { return }
        perform(action: .didTap(provider: provider))
    }
}

private extension OAuthViewController {
    static func makeOauthButton(provider: State.Provider) -> UIControl {
        switch provider {
        case .apple:
            return makeAppleButton()
        case let .thirdParty(provider):
            return makeThirdPartyButton(provider: provider)
        }
    }

    static func makeAppleButton() -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(type: .continue, style: .whiteOutline)
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: .buttonHeight),
        ])
        button.cornerRadius = .cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .brand
        return button
    }

    static func makeThirdPartyButton(provider: StytchClient.OAuth.ThirdParty.Provider) -> UIButton {
        let button = Button.secondary(
            image: provider.imageAsset,
            title: .localizedStringWithFormat(
                NSLocalizedString("stytch.oauthThirdPartyTitle", value: "Continue with %@", comment: ""),
                provider.rawValue.capitalized
            )
        ) {}
        button.removeTarget(nil, action: nil, for: .touchUpInside)
        return button
    }
}

enum OAuthVCAction {
    case didTap(provider: StytchUIClient.Configuration.OAuth.Provider)
}

private extension StytchClient.OAuth.ThirdParty.Provider {
    var imageAsset: ImageAsset? {
        .oauthIcon(self)
    }
}
