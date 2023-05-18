import PhoneNumberKit
import UIKit

final class AuthRootViewController: UIViewController {
    private let configuration: StytchUIClient.Configuration

    init(configuration: StytchUIClient.Configuration) {
        self.configuration = configuration

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let homeController = AuthHomeViewController(configuration: configuration) { [weak self] action in
            self?.handle(action: action)
        }
        let navigationController = UINavigationController(rootViewController: homeController)

        addChild(navigationController)
        view.addSubview(navigationController.view)
        navigationController.view.frame = view.bounds
    }

    func handle(action: AppAction) {
        switch action {
        case let .input(action):
            handle(inputAction: action)
        case let .oauth(action):
            handle(oauthAction: action)
        }
    }

    private func handle(inputAction: InputAction) {
        switch inputAction {
        case let .didTapContinueEmail(email):
            print(email)
        case let .didTapContinuePhone(phone):
            print(phone)
        case let .didTapCountryCode(input):
            let countryPickerViewController = CountryCodePickerViewController(phoneNumberKit: input.phoneNumberKit)
            countryPickerViewController.delegate = input
            let navigationController = UINavigationController(rootViewController: countryPickerViewController)
            present(navigationController, animated: true)
        }
    }

    private func handle(oauthAction: OAuthAction) {
        switch oauthAction {
        case let .didTap(provider):
            print(provider)
        }
    }
}
