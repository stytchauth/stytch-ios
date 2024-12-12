import AuthenticationServices
import StytchCore
import UIKit

protocol B2BOAuthViewControllerDelegate: AnyObject {
    func oauthDidAuthenticatie()
    func oauthDiscoveryDidAuthenticatie()
}

final class B2BOAuthViewController: BaseViewController<B2BOAuthState, B2BOAuthViewModel> {
    weak var delegate: B2BOAuthViewControllerDelegate?

    var filteredOauthProviders: [StytchB2BUIClient.B2BOAuthProviderOptions] {
        let configuration = viewModel.state.configuration
        let oauthProviders = configuration.oauthProviders
        switch configuration.authFlowType {
        case .discovery:
            // If we are in discovery just return what is passed in the UI config since we have no org set yet
            return oauthProviders
        case .organization(slug: _):
            // If we are in the org flow we need to check if we are in restricted mode and we have allowedAuthMethods
            // In that case we need to filter the oauth provider options by whatever is in the allowedAuthMethods
            // Otherwise we just return the array as specific in the ui config
            if let allowedAuthMethods = OrganizationManager.allowedAuthMethods, OrganizationManager.authMethods == .restricted {
                var filteredOauthProviders: [StytchB2BUIClient.B2BOAuthProviderOptions] = []
                for oauthProvider in oauthProviders {
                    if allowedAuthMethods.contains(oauthProvider.provider.allowedAuthMethodType) {
                        filteredOauthProviders.append(oauthProvider)
                    }
                }
                return filteredOauthProviders
            } else {
                return oauthProviders
            }
        }
    }

    init(state: B2BOAuthState, delegate: B2BOAuthViewControllerDelegate?) {
        super.init(viewModel: B2BOAuthViewModel(state: state))
        self.delegate = delegate
    }

    override func configureView() {
        super.configureView()

        view.layoutMargins = .zero

        filteredOauthProviders.enumerated().forEach { index, provider in
            let button = Self.makeOauthButton(provider: provider.provider)
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
        StytchB2BUIClient.startLoading()
        guard let (_, options) = viewModel.state.configuration.oauthProviders.enumerated().first(where: { $0.offset == sender.tag }) else { return }
        Task { [weak self] in
            do {
                if self?.viewModel.state.configuration.authFlowType == .discovery {
                    try await self?.viewModel.startDiscoveryOAuth(options: options)
                    self?.delegate?.oauthDiscoveryDidAuthenticatie()
                } else {
                    try await self?.viewModel.startOAuth(options: options)
                    self?.delegate?.oauthDidAuthenticatie()
                }
                StytchB2BUIClient.stopLoading()
            } catch {
                try? await EventsClient.logEvent(parameters: .init(eventName: "ui_authentication_failure", error: error))
                self?.presentErrorAlert(error: error)
                StytchB2BUIClient.stopLoading()
            }
        }
    }
}

private extension B2BOAuthViewController {
    static func makeOauthButton(provider: StytchB2BClient.OAuth.ThirdParty.Provider) -> UIControl {
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

private extension StytchB2BClient.OAuth.ThirdParty.Provider {
    var imageAsset: ImageAsset? {
        .b2bOauthIcon(self)
    }
}
