import AuthenticationServices
import StytchCore
import UIKit

final class B2BEmailConfirmationViewController: BaseViewController<B2BEmailConfirmationState, B2BEmailConfirmationViewModel> {
    init(state: B2BEmailConfirmationState) {
        super.init(viewModel: B2BEmailConfirmationViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        stackView.spacing = .spacingRegular

        let titleLabel: UILabel = .makeTitleLabel(text: viewModel.title)
        stackView.addArrangedSubview(titleLabel)

        let emailConfirmationLabel = UILabel.makeComboLabel(
            withPlainText: viewModel.message,
            boldText: MemberManager.emailAddress,
            fontSize: 18,
            alignment: .left
        )
        stackView.addArrangedSubview(emailConfirmationLabel)

        let tryAgainButton = Button.createTextButton(
            withPlainText: viewModel.primarySubtext,
            boldText: viewModel.secondaryBoldSubtext,
            action: #selector(buttonTapped),
            target: self
        )
        tryAgainButton.contentHorizontalAlignment = .leading
        stackView.addArrangedSubview(tryAgainButton)

        stackView.addArrangedSubview(SpacerView())

        attachStackViewToScrollView()

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
    }

    @objc func buttonTapped() {
        switch viewModel.state.type {
        case .emailConfirmation:
            navigationController?.popToRootViewController(animated: true)
        case .passwordSetNew:
            resetByEmailStart()
        case .passwordResetVerify:
            navigationController?.popToRootViewController(animated: true)
        }
    }

    func resetByEmailStart() {
        guard let emailAddress = MemberManager.emailAddress else {
            return
        }

        StytchB2BUIClient.startLoading()
        Task {
            do {
                try await viewModel.resendResetPasswordByEmailIfPossible(emailAddress: emailAddress)
                StytchB2BUIClient.stopLoading()
                presentAlert(title: LocalizationManager.stytch_b2b_email_confirmation_email_sent_alert_title)
            } catch {
                StytchB2BUIClient.stopLoading()
                ErrorPublisher.publishError(error)
                presentErrorAlert(error: error)
            }
        }
    }
}
