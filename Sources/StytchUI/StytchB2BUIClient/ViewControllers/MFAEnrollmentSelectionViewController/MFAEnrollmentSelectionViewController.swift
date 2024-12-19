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

        // TODO: Make sure not use the ordering as filtering
        // used to order the mfa methods
        var mfaMethods: [StytchB2BClient.MfaMethod] = [.sms, .totp]
        if let mfaProductOrder = viewModel.state.configuration.mfaProductOrder {
            mfaMethods = reorderMfaEnrollmentMethods(
                mfaProductOrder: mfaProductOrder,
                mfaEnrollmentMethods: viewModel.state.configuration.mfaEnrollmentMethods
            )
        }

        let mfaMethodSelectionViewController = MFAMethodSelectionViewController(mfaMethods: mfaMethods)
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

extension MFAEnrollmentSelectionViewController: MFAMethodSelectionViewControllerDelegate {
    func didSelectMFAMethod(mfaMethod: StytchCore.StytchB2BClient.MfaMethod) {
        switch mfaMethod {
        case .sms:
            navigationController?.pushViewController(SMSOTPEnrollmentViewController(state: .init(configuration: viewModel.state.configuration)), animated: true)
        case .totp:
            navigationController?.pushViewController(TOTPEnrollmentViewController(state: .init(configuration: viewModel.state.configuration)), animated: true)
        }
    }
}
