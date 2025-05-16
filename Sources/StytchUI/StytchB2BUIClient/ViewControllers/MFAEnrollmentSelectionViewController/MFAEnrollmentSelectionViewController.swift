import AuthenticationServices
import StytchCore
import UIKit

final class MFAEnrollmentSelectionViewController: BaseViewController<MFAEnrollmentSelectionState, MFAEnrollmentSelectionViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: LocalizationManager.stytch_b2b_mfa_enrollment_title
    )

    private let subtitleLabel: UILabel = .makeSubtitleLabel(
        text: LocalizationManager.stytch_b2b_mfa_enrollment_subtitle
    )

    init(state: MFAEnrollmentSelectionState) {
        super.init(viewModel: MFAEnrollmentSelectionViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        stackView.spacing = .spacingRegular

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)

        var mfaMethods: [StytchB2BClient.MfaMethod] = [.sms, .totp]
        if let mfaProductOrder = viewModel.state.configuration.mfaProductOrder {
            mfaMethods = reorderMfaEnrollmentMethods(
                mfaProductOrder: mfaProductOrder,
                mfaEnrollmentMethods: viewModel.state.configuration.mfaEnrollmentMethods
            )
        }

        let mfaMethodSelectionViewController = SelectionViewController(labels: mfaMethods.map(\.descriptionText))
        mfaMethodSelectionViewController.delegate = self
        addChild(mfaMethodSelectionViewController)
        stackView.addArrangedSubview(mfaMethodSelectionViewController.view)
        mfaMethodSelectionViewController.didMove(toParent: self)

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        view.backgroundColor = .background

        hideBackButton()
    }

    func reorderMfaEnrollmentMethods(
        mfaProductOrder: [StytchB2BClient.MfaMethod],
        mfaEnrollmentMethods: [StytchB2BClient.MfaMethod]
    ) -> [StytchB2BClient.MfaMethod] {
        guard let primaryMethod = mfaProductOrder.first else {
            return mfaEnrollmentMethods
        }

        var orderedMethods: [StytchB2BClient.MfaMethod] = []

        if mfaEnrollmentMethods.contains(primaryMethod) {
            orderedMethods.append(primaryMethod)
        }

        // Add the other method if present in mfaEnrollmentMethods and not already added
        for method in mfaEnrollmentMethods {
            if method != primaryMethod, !orderedMethods.contains(method) {
                orderedMethods.append(method)
                break // Stop after adding one extra method
            }
        }

        return orderedMethods
    }
}

extension MFAEnrollmentSelectionViewController: SelectionViewControllerDelegate {
    func didSelectCell(label: String) {
        if label == StytchB2BClient.MfaMethod.sms.descriptionText {
            navigationController?.pushViewController(SMSOTPEnrollmentViewController(state: .init(configuration: viewModel.state.configuration)), animated: true)
        } else if label == StytchB2BClient.MfaMethod.totp.descriptionText {
            navigationController?.pushViewController(TOTPEnrollmentViewController(state: .init(configuration: viewModel.state.configuration)), animated: true)
        }
    }
}

extension StytchB2BClient.MfaMethod {
    var descriptionText: String {
        switch self {
        case .sms:
            return LocalizationManager.stytch_b2b_mfa_selection_text
        case .totp:
            return LocalizationManager.stytch_b2b_mfa_selection_totp
        }
    }
}
