import AuthenticationServices
import StytchCore
import UIKit

final class PasswordAuthenticateViewController: BaseViewController<B2BPasswordsState, B2BPasswordsViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchPasswordAuthenticateTitle", value: "Log in with email and password", comment: "")
    )

    init(state: B2BPasswordsState) {
        super.init(viewModel: B2BPasswordsViewModel(state: state))
        viewModel.delegate = self
    }

    override func configureView() {
        super.configureView()

        stackView.spacing = .spacingRegular

        stackView.addArrangedSubview(titleLabel)

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
    }
}

extension PasswordAuthenticateViewController: B2BPasswordsViewModelDelegate {
    func didAuthenticateWithPassword() {}

    func didSendEmailMagicLink() {}

    func didError(error: any Error) {
        presentErrorAlert(error: error)
    }
}
