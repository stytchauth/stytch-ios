import AuthenticationServices
import StytchCore
import UIKit

final class SSODiscoveryFallbackViewController: BaseViewController<SSODiscoveryFallbackState, SSODiscoveryFallbackViewModel> {
    private lazy var organizationSlugInput: OrganizationSlugInput = .init()

    private lazy var continueButton: Button = .primary(title: "Continue") { [weak self] in
        self?.continueButtonTapped()
    }

    init(state: SSODiscoveryFallbackState) {
        super.init(viewModel: SSODiscoveryFallbackViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        let titleLabel = UILabel.makeTitleLabel(text: "Sorry, we couldn't find any connections")
        let subtitleLabel = UILabel.makeSubtitleLabel(text: "Please input the Organization's unique slug to continue. If you don't know the unique slug, log in through another method to view all of your available Organizations.")

        let tryAnotherLoginMethodButton = Button.createTextButton(
            withPlainText: "Try another login method",
            boldText: "",
            action: #selector(tryAnotherLoginMethodTapped),
            target: self
        )
        tryAnotherLoginMethodButton.contentHorizontalAlignment = .leading

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(organizationSlugInput)
        stackView.addArrangedSubview(continueButton)
        stackView.addArrangedSubview(tryAnotherLoginMethodButton)
        stackView.addArrangedSubview(SpacerView())

        attachStackViewToScrollView()

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
    }

    private func continueButtonTapped() {
        StytchB2BUIClient.startLoading()
        Task {
            do {
                try await OrganizationManager.getOrganizationBySlug(organizationSlug: organizationSlugInput.text ?? "")
                StytchB2BUIClient.stopLoading()
                Task { @MainActor in
                    let b2bAuthHomeViewController = B2BAuthHomeViewController(state: .init(configuration: viewModel.state.configuration))
                    navigationController?.pushViewController(b2bAuthHomeViewController, animated: true)
                }
            } catch {
                StytchB2BUIClient.stopLoading()
                ErrorPublisher.publishError(error)
                presentErrorAlert(error: error)
            }
        }
    }

    @objc func tryAnotherLoginMethodTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
}
