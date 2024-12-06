import AuthenticationServices
import StytchCore
import UIKit

final class MFAEnrollmentSelectionViewController: BaseViewController<MFAEnrollmentSelectionState, MFAEnrollmentSelectionViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchMfaEnrollmentTitle", value: "Set up Multi-Factor Authentication", comment: "")
    )

    private let subtitleLabel: UILabel = .makeSubtitleLabel(
        text: NSLocalizedString("stytchMfaEnrollmentSubtitle", value: "Add an additional form of verification to make your account more secure.", comment: "")
    )

    init(state: MFAEnrollmentSelectionState) {
        super.init(viewModel: MFAEnrollmentSelectionViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        stackView.spacing = .spacingRegular

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)

        let mfaMethodSelectionViewController = MFAMethodSelectionViewController(mfaMethods: [.sms, .totp])
        mfaMethodSelectionViewController.delegate = self
        addChild(mfaMethodSelectionViewController)
        stackView.addArrangedSubview(mfaMethodSelectionViewController.view)
        mfaMethodSelectionViewController.didMove(toParent: self)

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
    }
}

extension MFAEnrollmentSelectionViewController: MFAMethodSelectionViewControllerDelegate {
    func didSelectMFAMethod(mfaMethod: StytchCore.StytchB2BClient.MfaMethod) {
        switch mfaMethod {
        case .sms:
            handleSMSOTPEnrollment(configuration: viewModel.state.configuration)
        case .totp:
            handleTOTPEnrollment(configuration: viewModel.state.configuration)
        }
    }
}
