import AuthenticationServices
import StytchCore
import UIKit

enum OAuthVCAction {
    case didTap(provider: StytchUIClient.Configuration.OAuth.Provider)
}

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

    private static func makeOauthButton(provider: State.Provider) -> UIControl {
        switch provider {
        case .apple:
            return makeAppleButton()
        case let .thirdParty(provider):
            return makeThirdPartyButton(provider: provider)
        }
    }

    private static func makeAppleButton() -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(type: .continue, style: .whiteOutline)
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: .buttonHeight),
        ])
        button.cornerRadius = .cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .brand
        return button
    }

    private static func makeThirdPartyButton(provider: StytchClient.OAuth.ThirdParty.Provider) -> UIButton {
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

private extension StytchClient.OAuth.ThirdParty.Provider {
    var imageAsset: ImageAsset? {
        .oauthIcon(self)
    }
}

//
//    @objc private func didTapGoogle() {
//        Task {
//            do {
//                let (token, url) = try await StytchClient.oauth.google.start(
//                    parameters: StytchClient.OAuth.ThirdParty.WebAuthSessionStartParameters(
//                        loginRedirectUrl: URL(string: "uikit-example://login")!,
//                        signupRedirectUrl: URL(string: "uikit-example://signup")!
//                    )
//                )
//                let result = try await StytchClient.oauth.authenticate(parameters: .init(token: token))
//                print(url.pathComponents.last == "login" ? "Welcome back!" : "Welcome")
//                authenticate(response: result)
//            } catch {
//                print(error)
//            }
//        }
//    }
//
//    @objc private func didTapApple() {
//        Task {
//            do {
//                let result = try await StytchClient.oauth.apple.start(parameters: .init())
//                authenticate(response: result)
//            } catch {
//                print(error)
//            }
//        }
//    }
