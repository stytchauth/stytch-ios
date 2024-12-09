import AuthenticationServices
import StytchCore
import UIKit

final class SMSOTPEntryViewController: BaseViewController<SMSOTPEntryState, SMSOTPEntryViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchSMSOTPEntryTitle", value: "Enter passcode", comment: "")
    )

    init(state: SMSOTPEntryState) {
        super.init(viewModel: SMSOTPEntryViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        stackView.spacing = .spacingRegular

        stackView.addArrangedSubview(titleLabel)
        let otpView = OTPCodeEntryView(frame: .zero)
        otpView.delegate = self
        stackView.addArrangedSubview(otpView)

        stackView.addArrangedSubview(SpacerView())

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
    }
}

extension SMSOTPEntryViewController: OTPCodeEntryViewDelegate {
    func didEnterOTPCode(_: String) {}
}
