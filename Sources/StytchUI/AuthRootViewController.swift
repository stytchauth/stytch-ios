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

    private let activityIndicator: UIActivityIndicatorView = .init(style: .large)

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if !config.publicToken.isEmpty {
            StytchClient.configure(publicToken: config.publicToken)
        }

        activityIndicator.hidesWhenStopped = true

        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        overrideUserInterfaceStyle = .light

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
                magicLinksEnabled: false // TODO: confirm this is the desired behavior
            )
        ) { .password($0) }
        navController?.pushViewController(controller, animated: animated)
    }

    private func render(bootstrap: Bootstrap) {
        let homeController = AuthHomeViewController(state: .init(bootstrap: bootstrap, config: config)) { $0 }
        let navigationController = UINavigationController(rootViewController: homeController)
        navController = navigationController
        navigationController.navigationBar.tintColor = .label

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
            } catch {
                presentAlert(error: error)
            }
        // TODO: need way to tell whether user is new/returning
        }
    }

    private func handle(inputAction: AuthInputVCAction) async throws {
        switch inputAction {
        case let .didTapContinueEmail(email):
            switch config.input {
            case .magicLinkAndPassword, .password:
                let userSearch: UserSearchResponse = try await StytchClient._uiRouter.post(to: .userSearch, parameters: JSON.object(["email": .string(email)]))
                guard let intent = userSearch.userType.passwordIntent else {
                    try await handle(passwordAction: .didTapForgotPassword(email: email))
                    return
                }
                let controller = PasswordViewController(
                    state: .init(intent: intent, email: email, magicLinksEnabled: config.input.magicLinksEnabled)) { .password($0) }
                navController?.pushViewController(controller, animated: true)
            case .magicLink:
                _ = try await StytchClient.magicLinks.email.loginOrCreate(parameters: .init(email: email)) // FIXME: should take in magic link urls as part of config
                // FIXME: need to handle deeplinks
                let controller = ActionableInfoViewController(
                    state: .checkYourEmail(email: email) {
                        Task {
                            _ = try await StytchClient.magicLinks.email.loginOrCreate(parameters: .init(email: email)) // FIXME: should take in magic link urls as part of
                        }
                    }
                ) { .actionableInfo($0) }
                navController?.pushViewController(controller, animated: true)
            case .smsOnly, .none:
                break
            }
        case let .didTapContinuePhone(phone, formattedPhone):
            let expiry = Date().addingTimeInterval(120)
            let result = try await StytchClient.otps.loginOrCreate(parameters: .init(deliveryMethod: .sms(phoneNumber: phone)))
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

    private func handle(oauthAction: OAuthVCAction) async throws {
        switch oauthAction {
        case let .didTap(provider):
            switch provider {
            case .apple:
                _ = try await StytchClient.oauth.apple.start(parameters: .init())
            case let .thirdParty(provider):
                let (token, url) = try await provider.client.start(
                    parameters: .init(
                        loginRedirectUrl: .init(string: "stytch-auth://login")!,
                        signupRedirectUrl: .init(string: "stytch-auth://signup")!
                    )
                )
                _ = try await StytchClient.oauth.authenticate(parameters: .init(token: token))
            }
        }
    }

    private func handle(passwordAction: PasswordVCAction) async throws {
        switch passwordAction {
        case let .didTapEmailLoginLink(email):
            _ = try await StytchClient.magicLinks.email.loginOrCreate(parameters: .init(email: email)) // FIXME: use redirect urls from config
            let controller = ActionableInfoViewController(
                state: .checkYourEmail(email: email) {
                    Task {
                        _ = try await StytchClient.magicLinks.email.loginOrCreate(parameters: .init(email: email)) // FIXME: use redirect urls from config
                    }
                }
            ) { .actionableInfo($0) }
            navController?.pushViewController(controller, animated: true)
        case let .didTapLogin(email, password):
            _ = try await StytchClient.passwords.authenticate(parameters: .init(email: email, password: password))
        case let .didTapSignup(email, password):
            _ = try await StytchClient.passwords.create(parameters: .init(email: email, password: password))
        case let .didTapSetPassword(token, password):
            _ = try await StytchClient.passwords.resetByEmail(parameters: .init(token: token, password: password))
        case let .didTapForgotPassword(email):
            StytchUIClient.pendingResetEmail = email
            _ = try await StytchClient.passwords.resetByEmailStart(parameters: .init(email: email)) // FIXME: use redirect urls from config
            let controller = ActionableInfoViewController(
                state: .forgotPassword(email: email) {
                    Task {
                        _ = try await StytchClient.passwords.resetByEmailStart(parameters: .init(email: email)) // FIXME: use redirect urls from config
                    }
                }
            ) { .actionableInfo($0) }
            navController?.pushViewController(controller, animated: true)
        }
    }

    private func handle(otpAction: OTPVCAction) async throws {
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

    private func handle(aiAction: AIVCAction) async throws {
        switch aiAction {
        case let .didTapCreatePassword(email):
            try await handle(passwordAction: .didTapForgotPassword(email: email))
        case let .didTapLoginWithoutPassword(email):
            _ = try await StytchClient.magicLinks.email.loginOrCreate(parameters: .init(email: email)) // FIXME: grab redirect urls
            let controller = ActionableInfoViewController(
                state: .checkYourEmail(email: email) {
                    Task {
                        _ = try await StytchClient.magicLinks.email.loginOrCreate(parameters: .init(email: email)) // FIXME: grab redirect urls
                    }
                }
            ) { .actionableInfo($0) }
            navController?.pushViewController(controller, animated: true)
        }
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

private extension StytchUIClient.Configuration.Input? {
    var magicLinksEnabled: Bool {
        switch self {
        case .magicLink, .magicLinkAndPassword:
            return true
        case .password, .smsOnly, .none:
            return false
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
    // let emailDomains: [String]
    // let cnameDomain: String
    // let captchaSettings: JSON
    // let pkceRequiredForEmailMagicLinks: Bool?
    // let pkceRequiredForOauth: Bool?
    // let pkceRequiredForPasswordResets: Bool?
    // let pkceRequiredForSso: Bool?
    // let slugPattern: String
    // let createOrganizationEnabled: Bool
}

private struct UserSearchResponse: Decodable {
    enum UserType: String, Decodable {
        case new
        case password
        case passwordless
    }

    let userType: UserType
}
