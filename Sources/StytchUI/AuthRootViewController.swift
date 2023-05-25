import AuthenticationServices
import PhoneNumberKit
import StytchCore
import UIKit

final class AuthRootViewController: UIViewController {
    private let config: StytchUIClient.Configuration

    private var navController: UINavigationController?

    private let activityIndicator: UIActivityIndicatorView = .init(style: .large)

    init(config: StytchUIClient.Configuration) {
        self.config = config

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        StytchClient.configure(publicToken: config.publicToken)

        activityIndicator.hidesWhenStopped = true

        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        Task { @MainActor in
            defer { activityIndicator.stopAnimating() }
            activityIndicator.startAnimating()
            do {
                render(bootstrap: try await StytchClient._uiRouter.get(route: .bootstrap(publicToken: config.publicToken)))
            } catch {
                presentAlert(error: error)
            }
        }
    }

    func handlePasswordReset(token: String, email: String, animated: Bool = true) {
        let controller = PasswordViewController(
            state: .init(
                intent: .enterNewPassword(token: token),
                email: email,
                magicLinksEnabled: false
            )
        ) { .password($0) }
        navController?.pushViewController(controller, animated: animated)
    }

    @objc func dismissAuth() {
        presentingViewController?.dismiss(animated: true)
    }

    private func render(bootstrap: Bootstrap) {
        let homeController = AuthHomeViewController(state: .init(bootstrap: bootstrap, config: config)) { $0 }
        if let closeButton = config.navigation?.closeButtonStyle {
            let keyPath: ReferenceWritableKeyPath<UIViewController, UIBarButtonItem?>
            switch closeButton.position {
            case .left:
                keyPath = \.navigationItem.leftBarButtonItem
            case .right:
                keyPath = \.navigationItem.rightBarButtonItem
            }
            homeController[keyPath: keyPath] = .init(barButtonSystemItem: closeButton.barButtonSystemItem, target: self, action: #selector(dismissAuth))
        }
        let navigationController = UINavigationController(rootViewController: homeController)
        navController = navigationController
        navigationController.navigationBar.tintColor = .primaryText
        navigationController.navigationBar.barTintColor = .background
        navigationController.navigationBar.shadowImage = .init()

        addChild(navigationController)
        view.addSubview(navigationController.view)
        navigationController.view.frame = view.bounds
    }
}

extension AuthRootViewController: ActionDelegate {
    func handle(action: AuthHomeAction) {
        Task { @MainActor in
            do {
                switch action {
                case let .actionableInfo(action):
                    try await handle(aiAction: action)
                case let .input(action):
                    try await handle(inputAction: action)
                case let .oauth(action):
                    try await handle(oauthAction: action)
                case let .otp(action):
                    try await handle(otpAction: action)
                case let .password(action):
                    try await handle(passwordAction: action)
                }
            } catch ASAuthorizationError.canceled, ASWebAuthenticationSessionError.canceledLogin {
            } catch {
                presentAlert(error: error)
            }
        }
    }
}

private extension AuthRootViewController {
    func handle(inputAction: AuthInputVCAction) async throws {
        switch inputAction {
        case let .didTapContinueEmail(email):
            if config.magicLink != nil, let password = config.password {
                let userSearch: UserSearchResponse = try await StytchClient._uiRouter.post(to: .userSearch, parameters: JSON.object(["email": .string(email)]))
                guard let intent = userSearch.userType.passwordIntent else {
                    let params = params(email: email, password: password)
                    _ = try await StytchClient.passwords.resetByEmailStart(parameters: params)
                    let controller = ActionableInfoViewController(
                        state: .checkYourEmailResetReturning(email: email) { _ = try await StytchClient.passwords.resetByEmailStart(parameters: params) }
                    ) { .actionableInfo($0) }
                    navController?.pushViewController(controller, animated: true)
                    return
                }
                let controller = PasswordViewController(
                    state: .init(intent: intent, email: email, magicLinksEnabled: config.magicLink != nil)) { .password($0) }
                navController?.pushViewController(controller, animated: true)
            } else if let magicLink = config.magicLink {
                let parameters = params(email: email, magicLink: magicLink)
                _ = try await StytchClient.magicLinks.email.loginOrCreate(parameters: parameters)
                let controller = ActionableInfoViewController(
                    state: .checkYourEmail(email: email) { _ = try await StytchClient.magicLinks.email.loginOrCreate(parameters: parameters) }
                ) { .actionableInfo($0) }
                navController?.pushViewController(controller, animated: true)
            }
        case let .didTapContinuePhone(phone, formattedPhone):
            let expiry = Date().addingTimeInterval(120)
            let result = try await StytchClient.otps.loginOrCreate(parameters: .init(deliveryMethod: .sms(phoneNumber: phone), expiration: config.sms?.expiration))
            let controller = OTPCodeViewController(
                state: .init(
                    phoneNumberE164: phone,
                    formattedPhoneNumber: formattedPhone,
                    methodId: result.methodId,
                    codeExpiry: expiry
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

    func handle(oauthAction: OAuthVCAction) async throws {
        guard let oauth = config.oauth else { return }

        switch oauthAction {
        case let .didTap(provider):
            switch provider {
            case .apple:
                _ = try await StytchClient.oauth.apple.start(parameters: .init(sessionDuration: sessionDuration))
            case let .thirdParty(provider):
                let (token, _) = try await provider.client.start(
                    parameters: .init(loginRedirectUrl: oauth.loginRedirectUrl, signupRedirectUrl: oauth.signupRedirectUrl)
                )
                _ = try await StytchClient.oauth.authenticate(parameters: .init(token: token, sessionDuration: sessionDuration))
            }
        }
    }

    func handle(passwordAction: PasswordVCAction) async throws {
        switch passwordAction {
        case let .didTapEmailLoginLink(email):
            guard let magicLink = config.magicLink else { return }
            let params = params(email: email, magicLink: magicLink)
            _ = try await StytchClient.magicLinks.email.loginOrCreate(parameters: params)
            let controller = ActionableInfoViewController(
                state: .checkYourEmail(email: email) { _ = try await StytchClient.magicLinks.email.loginOrCreate(parameters: params) }
            ) { .actionableInfo($0) }
            navController?.pushViewController(controller, animated: true)
        case let .didTapLogin(email, password):
            _ = try await StytchClient.passwords.authenticate(parameters: .init(email: email, password: password, sessionDuration: sessionDuration))
        case let .didTapSignup(email, password):
            _ = try await StytchClient.passwords.create(parameters: .init(email: email, password: password, sessionDuration: sessionDuration))
        case let .didTapSetPassword(token, password):
            _ = try await StytchClient.passwords.resetByEmail(parameters: .init(token: token, password: password, sessionDuration: sessionDuration))
        case let .didTapForgotPassword(email):
            guard let password = config.password else { return }
            StytchUIClient.pendingResetEmail = email
            let params = params(email: email, password: password)
            _ = try await StytchClient.passwords.resetByEmailStart(parameters: params)
            let controller = ActionableInfoViewController(
                state: .forgotPassword(email: email) { _ = try await StytchClient.passwords.resetByEmailStart(parameters: params) }
            ) { .actionableInfo($0) }
            navController?.pushViewController(controller, animated: true)
        }
    }

    func handle(otpAction: OTPVCAction) async throws {
        switch otpAction {
        case let .didTapResendCode(phone, controller):
            let expiry = Date().addingTimeInterval(120)
            let result = try await StytchClient.otps.loginOrCreate(parameters: .init(deliveryMethod: .sms(phoneNumber: phone)))
            controller.state = .init(
                phoneNumberE164: phone,
                formattedPhoneNumber: controller.state.formattedPhoneNumber,
                methodId: result.methodId,
                codeExpiry: expiry
            )
        case let .didEnterCode(code, methodId, controller):
            do {
                _ = try await StytchClient.otps.authenticate(parameters: .init(code: code, methodId: methodId))
            } catch let error as StytchError where error.errorType == "otp_code_not_found" {
                controller.showInvalidCode()
            } catch {
                throw error
            }
        }
    }

    func handle(aiAction: AIVCAction) async throws {
        switch aiAction {
        case let .didTapCreatePassword(email):
            try await handle(passwordAction: .didTapForgotPassword(email: email))
        case let .didTapLoginWithoutPassword(email):
            guard let magicLink = config.magicLink else { return }
            let params = params(email: email, magicLink: magicLink)
            _ = try await StytchClient.magicLinks.email.loginOrCreate(parameters: params)
            let controller = ActionableInfoViewController(
                state: .checkYourEmail(email: email) { _ = try await StytchClient.magicLinks.email.loginOrCreate(parameters: params) }
            ) { .actionableInfo($0) }
            navController?.pushViewController(controller, animated: true)
        }
    }
}

private extension AuthRootViewController {
    var sessionDuration: Minutes {
        config.session?.sessionDuration ?? .defaultSessionDuration
    }

    func params(email: String, password: StytchUIClient.Configuration.Password) -> StytchClient.Passwords.ResetByEmailStartParameters {
        .init(
            email: email,
            loginUrl: password.loginURL,
            loginExpiration: password.loginExpiration,
            resetPasswordUrl: password.resetPasswordURL,
            resetPasswordExpiration: password.resetPasswordExpiration,
            resetPasswordTemplateId: password.resetPasswordTemplateId
        )
    }

    func params(email: String, magicLink: StytchUIClient.Configuration.MagicLink) -> StytchClient.MagicLinks.Email.Parameters {
        .init(
            email: email,
            loginMagicLinkUrl: magicLink.loginMagicLinkUrl,
            loginExpiration: magicLink.loginExpiration,
            loginTemplateId: magicLink.loginTemplateId,
            signupMagicLinkUrl: magicLink.signupMagicLinkUrl,
            signupExpiration: magicLink.signupExpiration,
            signupTemplateId: magicLink.signupTemplateId
        )
    }
}

private extension UserSearchResponse.UserType {
    var passwordIntent: PasswordVCState.Intent? {
        switch self {
        case .new:
            return .signup
        case .password:
            return .login
        case .passwordless:
            return nil
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

struct Bootstrap: Decodable {
    let disableSdkWatermark: Bool
}

private struct UserSearchResponse: Decodable {
    enum UserType: String, Decodable {
        case new
        case password
        case passwordless
    }

    let userType: UserType
}

private extension StytchUIClient.Configuration.Navigation.CloseButtonStyle {
    var barButtonSystemItem: UIBarButtonItem.SystemItem {
        switch self {
        case .cancel:
            return .cancel
        case .close:
            return .close
        case .done:
            return .done
        }
    }

    var position: StytchUIClient.Configuration.Navigation.BarButtonPosition {
        switch self {
        case let .cancel(position), let .close(position), let .done(position):
            return position
        }
    }
}
