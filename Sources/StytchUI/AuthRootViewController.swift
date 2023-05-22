import PhoneNumberKit
import StytchCore
import UIKit

final class AuthRootViewController: UIViewController {
    private let config: StytchUIClient.Configuration

    private var navController: UINavigationController?

    init(config: StytchUIClient.Configuration) {
        self.config = config

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let homeController = AuthHomeViewController(config) { $0 }
        let navigationController = UINavigationController(rootViewController: homeController)
        navController = navigationController
        navigationController.navigationBar.tintColor = .label

        addChild(navigationController)
        view.addSubview(navigationController.view)
        navigationController.view.frame = view.bounds
    }
}

extension AuthRootViewController: ActionDelegate {
    func handle(action: AppAction) {
        switch action {
        case let .actionableInfo(action):
            handle(aiAction: action)
        case let .input(action):
            handle(inputAction: action)
        case let .oauth(action):
            handle(oauthAction: action)
        case let .otp(action):
            handle(otpAction: action)
        case let .password(action):
            handle(passwordAction: action)
        }
    }

    private func handle(inputAction: AuthInputVCAction) {
        switch inputAction {
        case let .didTapContinueEmail(email):
            print(email)
            switch config.input {
            case .magicLinkAndPassword:
                // TODO: check if user is new/returning
                let controller = PasswordViewController(
                    state: .init(intent: .login, email: email, magicLinksEnabled: false)) { .password($0) }
                navController?.pushViewController(controller, animated: true)
            case .password:
                // TODO: check if user is new/returning
                let controller = PasswordViewController(
                    state: .init(intent: .login, email: email, magicLinksEnabled: false)) { .password($0) }
                navController?.pushViewController(controller, animated: true)
            case .magicLink:
                // TODO: fire off magic link and push actionable info
                break
            case .smsOnly, .none:
                break
            }
        case let .didTapContinuePhone(phone, formattedPhone):
            // TODO: fire off sms otp request
            let controller = OTPCodeViewController(
                state: .init(
                    phoneNumberE164: phone,
                    formattedPhoneNumber: formattedPhone,
                    methodId: "", // TODO: get methodID from request
                    codeExpiry: .init() // TODO: derive this value from the request
                )
            ) { .otp($0) }
            navController?.pushViewController(controller, animated: true)
        case let .didTapCountryCode(input):
            let countryPickerViewController = CountryCodePickerViewController(phoneNumberKit: input.phoneNumberKit)
            countryPickerViewController.delegate = input
            let navigationController = UINavigationController(rootViewController: countryPickerViewController)
            present(navigationController, animated: true)
        }
    }

    private func handle(oauthAction: OAuthVCAction) {
        switch oauthAction {
        case let .didTap(provider):
            switch provider {
            case .apple:
                Task {
                    let result = try await StytchClient.oauth.apple.start(parameters: .init())
                    // TODO: dismiss and pass back auth response
                }
            case let .thirdParty(provider):
                Task {
                    let (token, url) = try await provider.client.start(
                        parameters: .init(
                            loginRedirectUrl: .init(string: "")!,
                            signupRedirectUrl: .init(string: "")!
                        )
                    )
                    let result = try await StytchClient.oauth.authenticate(parameters: .init(token: token))
                    // TODO: dismiss, pass back auth response (and tell whether new/returning)
                }
            }
            print(provider)
        }
    }

    private func handle(passwordAction: PasswordVCAction) {
        print(passwordAction)
        switch passwordAction {
        case let .didTapEmailLoginLink(email):
            // TODO: send login link
            let controller = ActionableInfoViewController(state: .checkYourEmail(email: email)) { .actionableInfo($0) }
            navController?.pushViewController(controller, animated: true)
        case let .didTapLogin(email, password):
            break
        case let .didTapSignup(email, password):
            break
        case let .didTapSetPassword(email, password):
            break
        case let .didTapForgotPassword(email):
            // TODO: initiate pw reset
            let controller = ActionableInfoViewController(state: .forgotPassword(email: email)) { .actionableInfo($0) }
            navController?.pushViewController(controller, animated: true)
        }
    }

    private func handle(otpAction: OTPVCAction) {
        switch otpAction {
        case let .didTapResendCode(phone):
            // TODO present alert, and update VC after send code confirmation is pressed
            print(phone)
        case let .didEnterCode(code, methodId):
            print(code)
        }
    }

    private func handle(aiAction: AIVCAction) {
        print(aiAction)
        switch aiAction {
        case .didTapCreatePassword:
            break
        case let .didTapLoginWithoutPassword(email):
            // TODO: send email
            let controller = ActionableInfoViewController(state: .checkYourEmail(email: email)) { .actionableInfo($0) }
            navController?.pushViewController(controller, animated: true)
            break
        }
    }
}

private extension StytchClient.OAuth.ThirdParty.Provider {
    var client: StytchClient.OAuth.ThirdParty {
        switch self {
        case .amazon:
            return StytchClient.oauth.amazon
        case .bitbucket:
            return StytchClient.oauth.bitbucket
        case .coinbase:
            return StytchClient.oauth.coinbase
        case .discord:
            return StytchClient.oauth.discord
        case .facebook:
            return StytchClient.oauth.facebook
        case .figma:
            return StytchClient.oauth.figma
        case .github:
            return StytchClient.oauth.github
        case .gitlab:
            return StytchClient.oauth.gitlab
        case .google:
            return StytchClient.oauth.google
        case .linkedin:
            return StytchClient.oauth.linkedin
        case .microsoft:
            return StytchClient.oauth.microsoft
        case .salesforce:
            return StytchClient.oauth.salesforce
        case .slack:
            return StytchClient.oauth.slack
        case .snapchat:
            return StytchClient.oauth.snapchat
        case .spotify:
            return StytchClient.oauth.spotify
        case .tiktok:
            return StytchClient.oauth.tiktok
        case .twitch:
            return StytchClient.oauth.twitch
        case .twitter:
            return StytchClient.oauth.twitter
        }
    }
}
