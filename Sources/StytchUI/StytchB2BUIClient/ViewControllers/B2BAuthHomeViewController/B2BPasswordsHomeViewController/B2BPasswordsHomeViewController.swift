import AuthenticationServices
import StytchCore
import UIKit

protocol B2BPasswordsHomeViewControllerDelegate: AnyObject {
    func didAuthenticateWithPassword()
    func didDiscoveryAuthenticateWithPassword()
    func didSendEmailMagicLink()
}

final class B2BPasswordsHomeViewController: BaseViewController<B2BPasswordsState, B2BPasswordsViewModel> {
    weak var delegate: B2BPasswordsHomeViewControllerDelegate?

    private let emailInputLabel = UILabel.makeEmailInputLabel()

    private lazy var emailInput: EmailInput = .init()

    private let passwordInputLabel = UILabel.makePasswordInputLabel()

    private lazy var passwordInput: SecureTextInput = {
        let input: SecureTextInput = .init(frame: .zero)
        input.textInput.textContentType = .password
        input.textInput.rightViewMode = .always
        return input
    }()

    private lazy var continueButton: Button = .primary(
        title: LocalizationManager.stytch_continue_button
    ) { [weak self] in
        self?.submit()
    }

    init(state: B2BPasswordsState, delegate: B2BPasswordsHomeViewControllerDelegate?) {
        super.init(viewModel: B2BPasswordsViewModel(state: state))
        self.delegate = delegate
        viewModel.delegate = self
    }

    override func configureView() {
        super.configureView()

        view.layoutMargins = .zero

        stackView.spacing = .spacingRegular

        stackView.addArrangedSubview(emailInputLabel)
        stackView.addArrangedSubview(emailInput)
        stackView.addArrangedSubview(passwordInputLabel)
        stackView.addArrangedSubview(passwordInput)
        stackView.addArrangedSubview(continueButton)

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        NSLayoutConstraint.activate([
            continueButton.heightAnchor.constraint(equalToConstant: .buttonHeight),
        ])

        emailInput.setReturnKeyType(returnKeyType: .next)
        emailInput.shouldResignFirstResponderOnReturn = false

        emailInput.onReturn = { [weak self] _ in
            self?.passwordInput.assignFirstResponder()
        }

        passwordInput.onReturn = { [weak self] _ in
            self?.submit()
        }
    }

    private func submit() {
        let emailAddress = emailInput.text ?? ""
        let password = passwordInput.text ?? ""
        viewModel.authenticateWithPasswordIfPossible(emailAddress: emailAddress, password: password)
    }
}

extension B2BPasswordsHomeViewController: B2BPasswordsViewModelDelegate {
    func didAuthenticate() {
        delegate?.didAuthenticateWithPassword()
    }

    func didDiscoveryAuthenticate() {
        delegate?.didDiscoveryAuthenticateWithPassword()
    }

    func didSendEmailMagicLink() {
        delegate?.didSendEmailMagicLink()
    }

    func didError(error: any Error) {
        showEmailNotEligibleForJitProvioningErrorIfPossible(error)
        passwordInput.updateText("")
    }
}
