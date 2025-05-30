import AuthenticationServices
import StytchCore
import UIKit

final class TOTPEnrollmentViewController: BaseViewController<TOTPEnrollmentState, TOTPEnrollmentViewModel> {
    let totpSecretView = TOTPSecretView(secret: "---")

    var error: Error?

    private let titleLabel: UILabel = .makeTitleLabel(
        text: LocalizationManager.stytch_b2b_totp_enrollment_title
    )

    private let subtitleLabel: UILabel = .makeSubtitleLabel(
        text: LocalizationManager.stytch_b2b_totp_enrollment_subtitle
    )

    private lazy var continueButton: Button = .primary(
        title: LocalizationManager.stytch_continue_button
    ) { [weak self] in
        self?.continueWithTOTP()
    }

    init(state: TOTPEnrollmentState) {
        super.init(viewModel: TOTPEnrollmentViewModel(state: state))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createTOTP()
    }

    override func configureView() {
        super.configureView()

        stackView.spacing = .spacingRegular
        totpSecretView.delegate = self

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(totpSecretView)
        stackView.addArrangedSubview(continueButton)
        stackView.addArrangedSubview(SpacerView())
        attachStackViewToScrollView()

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        NSLayoutConstraint.activate([
            continueButton.heightAnchor.constraint(equalToConstant: .buttonHeight),
        ])
    }

    private func continueWithTOTP() {
        if error != nil {
            createTOTP()
        } else {
            navigationController?.pushViewController(TOTPEntryViewController(state: .init(configuration: viewModel.state.configuration)), animated: true)
        }
    }

    @objc func createTOTP() {
        StytchB2BUIClient.startLoading()
        Task { [weak self] in
            do {
                let secret = try await self?.viewModel.createTOTP()
                Task { @MainActor in
                    self?.continueButton.setTitle(LocalizationManager.stytch_continue_button, for: .normal)
                    self?.totpSecretView.configure(with: secret ?? "")
                    self?.error = nil
                    StytchB2BUIClient.stopLoading()
                }
            } catch {
                Task { @MainActor in
                    self?.continueButton.setTitle(LocalizationManager.stytch_b2c_password_continue_try_again_title, for: .normal)
                    ErrorPublisher.publishError(error)
                    self?.presentErrorAlert(error: error)
                    self?.error = error
                    StytchB2BUIClient.stopLoading()
                }
            }
        }
    }
}

extension TOTPEnrollmentViewController: TOTPSecretViewDelegate {
    func didCopyTOTPSecret() {
        presentAlert(title: LocalizationManager.stytch_b2b_totp_secret_copied, message: nil)
    }
}
