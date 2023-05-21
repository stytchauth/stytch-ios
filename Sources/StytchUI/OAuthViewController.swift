import AuthenticationServices
import StytchCore
import UIKit

final class OAuthViewController: BaseViewController<StytchUIClient.Configuration.OAuth, Never, OAuthAction> {
    private lazy var googleButton: Button = .secondary(
        image: .google,
        title: NSLocalizedString("stytch.oauthGoogleTitle", value: "Continue with Google", comment: "")
    ) {}

    private lazy var appleButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .continue, style: .whiteOutline)
        button.cornerRadius = .cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .brand
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        config.providers.forEach { provider in
            switch provider {
            case .apple:
                stackView.addArrangedSubview(appleButton)
            case .thirdParty(.google):
                stackView.addArrangedSubview(googleButton)
            case .thirdParty(_):
                fatalError("NOT SUPPORTED") // FIXME
            }
        }

        attachStackView(within: view)

        NSLayoutConstraint.activate([
            googleButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            appleButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            appleButton.heightAnchor.constraint(equalToConstant: .buttonHeight),
        ])

        googleButton.addTarget(self, action: #selector(didTapGoogle), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(didTapApple), for: .touchUpInside)
    }

    // TODO: allow passing in/laying out via configuration object
    // TODO: enable callback post auth

    private func authenticate(response: AuthenticateResponseType) {
        // FIXME: - do something
    }

    @objc private func didTapGoogle() {
        Task {
            do {
                let (token, url) = try await StytchClient.oauth.google.start(
                    parameters: StytchClient.OAuth.ThirdParty.WebAuthSessionStartParameters(
                        loginRedirectUrl: URL(string: "uikit-example://login")!,
                        signupRedirectUrl: URL(string: "uikit-example://signup")!
                    )
                )
                let result = try await StytchClient.oauth.authenticate(parameters: .init(token: token))
                print(url.pathComponents.last == "login" ? "Welcome back!" : "Welcome")
                authenticate(response: result)
            } catch {
                print(error)
            }
        }
    }

    @objc private func didTapApple() {
        Task {
            do {
                let result = try await StytchClient.oauth.apple.start(parameters: .init())
                authenticate(response: result)
            } catch {
                print(error)
            }
        }
    }
}
