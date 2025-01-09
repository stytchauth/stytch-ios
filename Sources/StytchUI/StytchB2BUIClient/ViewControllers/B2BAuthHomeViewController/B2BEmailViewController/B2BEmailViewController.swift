import AuthenticationServices
import StytchCore
import UIKit

protocol B2BEmailViewControllerDelegate: AnyObject {
    func emailMagicLinkSent()
    func emailOTPSent()
    func showEmailMethodSelection()
    func usePasswordInstead()
}

final class B2BEmailViewController: BaseViewController<B2BEmailState, B2BEmailViewModel> {
    weak var delegate: B2BEmailViewControllerDelegate?
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

    init(state: B2BEmailState, showsUsePasswordButton: Bool, delegate: B2BEmailViewControllerDelegate?) {
        self.showsUsePasswordButton = showsUsePasswordButton
        self.delegate = delegate
        super.init(viewModel: B2BEmailViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        view.layoutMargins = .zero

        stackView.spacing = .spacingRegular

        stackView.addArrangedSubview(emailInput)
        stackView.addArrangedSubview(continueButton)

        let isDicoveryFlow = viewModel.state.configuration.computedAuthFlowType == .discovery
        if showsUsePasswordButton == true, isDicoveryFlow == false {
            stackView.addArrangedSubview(usePasswordInsteadButton)
        }

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        continueButton.isEnabled = false

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
        MemberManager.updateMemberEmailAddress(emailInput.text ?? "")

        let configuration = viewModel.state.configuration
        if configuration.supportsEmailMagicLinksAndEmailOTP {
            delegate?.showEmailMethodSelection()
        } else if configuration.supportsEmailMagicLinks {
            sendEmailMagicLink()
        } else if configuration.supportsEmailOTP {
            sendEmailOTP()
        }
    }

    func sendEmailMagicLink() {
        viewModel.sendEmailMagicLink(emailAddress: emailInput.text ?? "") { [weak self] error in
            if let error {
                self?.presentErrorAlert(error: error)
            } else {
                self?.delegate?.emailMagicLinkSent()
            }
        }
    }

    func sendEmailOTP() {
        viewModel.sendEmailOTP(emailAddress: emailInput.text ?? "") { [weak self] error in
            if let error {
                self?.presentErrorAlert(error: error)
            } else {
                self?.delegate?.emailOTPSent()
            }
        }
    }

    private func usePasswordInsteadButtonTapped() {
        delegate?.usePasswordInstead()
    }
}
