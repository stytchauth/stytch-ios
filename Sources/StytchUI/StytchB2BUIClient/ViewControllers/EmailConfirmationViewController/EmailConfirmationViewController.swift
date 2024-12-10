import AuthenticationServices
import StytchCore
import UIKit

final class EmailConfirmationViewController: BaseViewController<EmailConfirmationState, EmailConfirmationViewModel> {
    init(state: EmailConfirmationState) {
        super.init(viewModel: EmailConfirmationViewModel(state: state))
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

        attachStackView(within: view)

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

        Task {
            do {
                try await viewModel.resetByEmailStart(emailAddress: emailAddress)
                presentAlert(title: "Email Sent!")
            } catch {
                presentErrorAlert(error: error)
            }
        }
    }
}
