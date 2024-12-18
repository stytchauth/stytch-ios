import AuthenticationServices
import StytchCore
import UIKit

protocol B2BOAuthViewControllerDelegate: AnyObject {
    func oauthDidAuthenticatie()
    func oauthDiscoveryDidAuthenticatie()
}

final class B2BOAuthViewController: BaseViewController<B2BOAuthState, B2BOAuthViewModel> {
    weak var delegate: B2BOAuthViewControllerDelegate?

    init(state: B2BOAuthState, delegate: B2BOAuthViewControllerDelegate?) {
        super.init(viewModel: B2BOAuthViewModel(state: state))
        self.delegate = delegate
    }

    override func configureView() {
        super.configureView()

        view.layoutMargins = .zero

        viewModel.state.configuration.filteredOauthProviders.enumerated().forEach { index, provider in
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
                if self?.viewModel.state.configuration.computedAuthFlowType == .discovery {
                    try await self?.viewModel.startDiscoveryOAuth(options: options)
                    self?.delegate?.oauthDiscoveryDidAuthenticatie()
                } else {
                    try await self?.viewModel.startOAuth(options: options)
                    self?.delegate?.oauthDidAuthenticatie()
                }
                StytchB2BUIClient.stopLoading()
            } catch {
                if let error = error as? ASWebAuthenticationSessionError, error.code == .canceledLogin {
                    // do nothing
                } else {
                    self?.presentErrorAlert(error: error)
                    try? await EventsClient.logEvent(parameters: .init(eventName: "ui_authentication_failure", error: error))
                }
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
