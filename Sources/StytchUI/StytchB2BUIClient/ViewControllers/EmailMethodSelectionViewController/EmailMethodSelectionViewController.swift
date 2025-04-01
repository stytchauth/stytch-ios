import AuthenticationServices
import StytchCore
import UIKit

final class EmailMethodSelectionViewController: BaseViewController<EmailMethodSelectionState, EmailMethodSelectionViewModel> {
    let emailMagicLinkLabelText = "Email me a log in link"
    let emailOTPLabelText = "Email me a log in code"

    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchEmailMethodTitle", value: "Select how you'd like to continue.", comment: "")
    )

    init(state: EmailMethodSelectionState) {
        super.init(viewModel: EmailMethodSelectionViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        stackView.spacing = .spacingRegular

        stackView.addArrangedSubview(titleLabel)

        let emailMethodSelectionViewController = SelectionViewController(labels: [emailMagicLinkLabelText, emailOTPLabelText])
        emailMethodSelectionViewController.delegate = self
        addChild(emailMethodSelectionViewController)
        stackView.addArrangedSubview(emailMethodSelectionViewController.view)
        emailMethodSelectionViewController.didMove(toParent: self)

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        view.backgroundColor = .background
    }

    func sendEmailMagicLink() {
        viewModel.sendEmailMagicLink(emailAddress: MemberManager.emailAddress ?? "") { [weak self] error in
            if let error {
                ErrorPublisher.publishError(error)
                self?.presentErrorAlert(error: error)
            } else {
                self?.emailMagicLinkSent()
            }
        }
    }

    func sendEmailOTP() {
        viewModel.sendEmailOTP(emailAddress: MemberManager.emailAddress ?? "") { [weak self] error in
            if let error {
                ErrorPublisher.publishError(error)
                self?.presentErrorAlert(error: error)
            } else {
                self?.emailOTPSent()
            }
        }
    }

    func emailOTPSent() {
        Task { @MainActor in
            let emailOTPEntryViewController = EmailOTPEntryViewController(state: .init(configuration: viewModel.state.configuration, didSendCode: true))
            navigationController?.pushViewController(emailOTPEntryViewController, animated: true)
        }
    }

    func emailMagicLinkSent() {
        showEmailConfirmation(configuration: viewModel.state.configuration, type: .emailConfirmation)
    }
}

extension EmailMethodSelectionViewController: SelectionViewControllerDelegate {
    func didSelectCell(label: String) {
        if label == emailMagicLinkLabelText {
            sendEmailMagicLink()
        } else if label == emailOTPLabelText {
            sendEmailOTP()
        }
    }
}
