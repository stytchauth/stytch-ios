import PhoneNumberKit
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
            print(action)
        case let .input(action):
            handle(inputAction: action)
        case let .oauth(action):
            handle(oauthAction: action)
        case let .otp(action):
            print(action)
        case let .password(action):
            print(action)
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
            print(provider)
        }
    }
}
