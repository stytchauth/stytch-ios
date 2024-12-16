import AuthenticationServices
import StytchCore
import UIKit

protocol B2BEmailMagicLinksViewControllerDelegate: AnyObject {
    func emailMagicLinkSent()
    func usePasswordInstead()
}

final class B2BEmailMagicLinksViewController: BaseViewController<B2BEmailMagicLinksState, B2BEmailMagicLinksViewModel> {
    weak var delegate: B2BEmailMagicLinksViewControllerDelegate?
    let showsUsePasswordButton: Bool

    private lazy var emailInput: EmailInput = .init()

    private lazy var continueButton: Button = .primary(
        title: NSLocalizedString("stytch.pwContinueTitle", value: "Continue with email", comment: "")
    ) { [weak self] in
        self?.continueButtonTapped()
    }

    private lazy var usePasswordInsteadButton: Button = {
        let button = Button.tertiary(
            title: NSLocalizedString("stytch.forgotPassword", value: "Use password instead", comment: "")
        ) { [weak self] in
            self?.usePasswordInsteadButtonTapped()
        }
        button.setTitleColor(.secondaryText, for: .normal)
        return button
    }()

    init(state: B2BEmailMagicLinksState, showsUsePasswordButton: Bool, delegate: B2BEmailMagicLinksViewControllerDelegate?) {
        self.showsUsePasswordButton = showsUsePasswordButton
        self.delegate = delegate
        super.init(viewModel: B2BEmailMagicLinksViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        view.layoutMargins = .zero

        stackView.spacing = .spacingRegular

        stackView.addArrangedSubview(emailInput)
        stackView.addArrangedSubview(continueButton)

        let isDicoveryFlow = viewModel.state.configuration.authFlowType == .discovery
        if showsUsePasswordButton == true, isDicoveryFlow == false {
            stackView.addArrangedSubview(usePasswordInsteadButton)
        }

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        setupEmailInput(input: emailInput)
    }

    private func setupEmailInput(input: EmailInput) {
        input.onTextChanged = { [weak self] isValid in
            guard let self else { return }

            self.continueButton.isEnabled = isValid

            switch (input.hasBeenValid, isValid) {
            case (_, true):
                input.setFeedback(nil)
            case (true, false):
                input.setFeedback(
                    .error(
                        NSLocalizedString("stytch.invalidEmail", value: "Invalid email address, please try again.", comment: "")
                    )
                )
            case (false, false):
                break
            }
        }

        input.onReturn = { [weak self] isValid in
            if isValid == true {
                self?.continueButtonTapped()
            }
        }
    }

    private func continueButtonTapped() {
        viewModel.sendEmailMagicLink(emailAddress: emailInput.text ?? "") { [weak self] error in
            if let error {
                self?.presentErrorAlert(error: error)
            } else {
                self?.delegate?.emailMagicLinkSent()
            }
        }
    }

    private func usePasswordInsteadButtonTapped() {
        delegate?.usePasswordInstead()
    }
}
