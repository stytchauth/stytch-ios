import AuthenticationServices
import StytchCore
import UIKit

final class OAuthViewController: BaseViewController<OAuthState, OAuthViewModel> {
    init(state: OAuthState) {
        super.init(viewModel: OAuthViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 12

        view.layoutMargins = .zero

        viewModel.state.config.oauthProviders.enumerated().forEach { index, provider in
            let button = makeOauthButton(provider: provider)
            button.tag = index
            button.addTarget(self, action: #selector(didTapOAuthButton(sender:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }

        attachStackView(within: view)
    }

    @objc private func didTapOAuthButton(sender: UIControl) {
        guard let (_, provider) = viewModel.state.config.oauthProviders.enumerated().first(where: { $0.offset == sender.tag }) else { return }
        StytchUIClient.startLoading()
        Task {
            do {
                StytchUIClient.stopLoading()
                try await viewModel.startOAuth(provider: provider)
            } catch {
                StytchUIClient.stopLoading()
                try? await EventsClient.logEvent(parameters: .init(eventName: "ui_authentication_failure", error: error))
                ErrorPublisher.publishError(error)
                presentErrorAlert(error: error)
            }
        }
    }

    func makeOauthButton(provider: StytchUIClient.OAuthProvider) -> UIControl {
        let button: Button
        switch provider {
        case .apple:
            button = Button.oauth(image: .appleOauthIcon) {}
        case let .thirdParty(provider):
            button = Button.oauth(image: provider.imageAsset) {}
        }
        button.removeTarget(nil, action: nil, for: .touchUpInside)
        return button
    }
}

private extension StytchClient.OAuth.ThirdParty.Provider {
    var imageAsset: ImageAsset? {
        .oauthIcon(self)
    }
}
