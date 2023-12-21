import UIKit

final class ActionableInfoViewModel: BaseViewModel<ActionableInfoState, ActionableInfoAction> {

}

final class ActionableInfoViewController: BaseViewController<ActionableInfoState, ActionableInfoAction, ActionableInfoViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        label.textColor = .primaryText
        return label
    }()

    private let retryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.secondaryText, for: .normal)
        button.contentHorizontalAlignment = .leading
        button.titleLabel?.numberOfLines = 0
        return button
    }()

    private lazy var separatorView: LabelSeparatorView = .orSeparator()

    private lazy var secondaryActionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.titleLabel?.numberOfLines = 0
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        retryButton.addTarget(self, action: #selector(didTapRetry(sender:)), for: .touchUpInside)
        secondaryActionButton.addTarget(self, action: #selector(didTapSecondaryAction(sender:)), for: .touchUpInside)

        view.layoutMargins = .init(top: .verticalMargin, left: .horizontalMargin, bottom: .verticalMargin, right: .horizontalMargin)
        stackView.spacing = .spacingHuge
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(infoLabel)
        stackView.addArrangedSubview(retryButton)

        if let secondaryAction = viewModel.state.secondaryAction {
            stackView.addArrangedSubview(separatorView)
            stackView.setCustomSpacing(38, after: separatorView)
            secondaryActionButton.setTitle(secondaryAction.title, for: .normal)
            stackView.addArrangedSubview(secondaryActionButton)
        }

        stackView.addArrangedSubview(SpacerView())

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
    }

    override func update(state: State) {
        titleLabel.text = state.title
        let (info, action) = attrStrings(state: state)
        infoLabel.attributedText = info
        retryButton.setAttributedTitle(action, for: .normal)
    }

    @objc private func didTapRetry(sender _: UIButton) {
        let controller = UIAlertController(
            title: NSLocalizedString("stytch.aiResendCode", value: "Resend link", comment: ""),
            message: .localizedStringWithFormat(
                NSLocalizedString("stytch.aiNewCodeWillBeSent", value: "A new link will be sent to %@.", comment: ""), viewModel.state.email
            ),
            preferredStyle: .alert
        )
        controller.addAction(.init(title: NSLocalizedString("stytch.aiCancel", value: "Cancel", comment: ""), style: .default))
        controller.addAction(.init(title: NSLocalizedString("stytch.aiConfirm", value: "Send link", comment: ""), style: .default) { [weak self] _ in
            Task { @MainActor in
                try await self?.viewModel.state.retryAction()
            }
        })
        controller.view.tintColor = .primaryText
        present(controller, animated: true)
    }

    @objc private func didTapSecondaryAction(sender _: UIButton) {
        guard let (_, action) = viewModel.state.secondaryAction else { return }
        viewModel.perform(action: action)
    }

    private func attrStrings(state: ActionableInfoState) -> (info: NSAttributedString, action: NSAttributedString) {
        let transformer: ([AttrStringComponent]) -> NSAttributedString = { components in
            components.reduce(into: NSMutableAttributedString(string: "")) { partial, next in
                switch next {
                case let .bold(.string(string)):
                    partial.append(.init(string: string, attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .semibold)]))
                case let .string(string):
                    partial.append(.init(string: string, attributes: [.font: UIFont.systemFont(ofSize: 16)]))
                default:
                    break
                }
            }
        }
        return (info: transformer(state.infoComponents), action: transformer(state.actionComponents))
    }
}

struct ActionableInfoState: BaseState {
    let email: String
    let title: String
    let infoComponents: [AttrStringComponent]
    let actionComponents: [AttrStringComponent]
    let secondaryAction: (title: String, action: ActionableInfoAction)?
    let retryAction: RetryAction
}

enum ActionableInfoAction: BaseAction {
    case didTapCreatePassword(email: String)
    case didTapLoginWithoutPassword(email: String)
}

extension ActionableInfoState {
    typealias RetryAction = () async throws -> Void
    static func forgotPassword(email: String, retryAction: @escaping RetryAction) -> Self {
        .init(
            email: email,
            title: NSLocalizedString("stytch.aiForgotPW", value: "Forgot password?", comment: ""),
            infoComponents: [
                .string(NSLocalizedString("stytch.linkToResetPWSent", value: "A link to reset your password was sent to you at ", comment: "")),
                .bold(.string(email)),
            ],
            actionComponents: .didntGetItResendEmail,
            secondaryAction: nil,
            retryAction: retryAction
        )
    }

    static func checkYourEmail(email: String, retryAction: @escaping RetryAction) -> Self {
        .init(
            email: email,
            title: .checkEmail,
            infoComponents: [.string(.loginLinkSentToYou), .bold(.string(email)), "."],
            actionComponents: .didntGetItResendEmail,
            secondaryAction: nil,
            retryAction: retryAction
        )
    }

    static func checkYourEmailCreatePWInstead(email: String, retryAction: @escaping RetryAction) -> Self {
        .init(
            email: email,
            title: .checkEmail,
            infoComponents: [.string(.loginLinkSentToYou), .bold(.string(email)), "."],
            actionComponents: .didntGetItResendEmail,
            secondaryAction: (NSLocalizedString("stytch.aiCreatePWInstead", value: "Create a password instead", comment: ""), .didTapCreatePassword(email: email)),
            retryAction: retryAction
        )
    }

    static func checkYourEmailReset(email: String, retryAction: @escaping RetryAction) -> Self {
        .init(
            email: email,
            title: .checkEmailForNewPW,
            infoComponents: [
                .string(.loginLinkSentToYou),
                .bold(.string(email)),
                .string(NSLocalizedString("stytch.toCreatePW", value: " to create a password for your account.", comment: "")),
            ],
            actionComponents: .didntGetItResendEmail,
            secondaryAction: nil,
            retryAction: retryAction
        )
    }

    static func checkYourEmailResetReturning(email: String, retryAction: @escaping RetryAction) -> Self {
        .init(
            email: email,
            title: .checkEmailForNewPW,
            infoComponents: [
                .string(NSLocalizedString("stytch.aiMakeSureAcctSecure", value: "We want to make sure your account is secure and that it’s really you logging in. A login link was sent to you at ", comment: "")),
                .bold(.string(email)),
                .string(.period),
            ],
            actionComponents: .didntGetItResendEmail,
            secondaryAction: (.loginWithoutPW, .didTapLoginWithoutPassword(email: email)),
            retryAction: retryAction
        )
    }

    static func checkYourEmailResetBreached(email: String, retryAction: @escaping RetryAction) -> Self {
        .init(
            email: email,
            title: .checkEmailForNewPW,
            infoComponents: [
                .string(NSLocalizedString("stytch.aiPWBreach", value: "A different site where you use the same password had a security issue recently. For your safety, an email was sent to you at ", comment: "")),
                .bold(.string(email)),
                .string(NSLocalizedString("stytch.toResetPW", value: " to reset your password.", comment: "")),
            ],
            actionComponents: .didntGetItResendEmail,
            secondaryAction: (.loginWithoutPW, .didTapLoginWithoutPassword(email: email)),
            retryAction: retryAction
        )
    }
}

extension [AttrStringComponent] {
    static var didntGetItResendEmail: Self {
        [
            .string(NSLocalizedString("stytch.aiDidntGetIt", value: "Didn't get it? ", comment: "")),
            .bold(.string(NSLocalizedString("stytch.aiResendEmail", value: "Resend email", comment: ""))),
        ]
    }
}

private extension String {
    static let checkEmail: String = NSLocalizedString("stytch.aiCheckEmail", value: "Check your email", comment: "")
    static let checkEmailForNewPW: String = NSLocalizedString("stytch.aiCheckEmailForPW", value: "Check your email to set a new password", comment: "")
    static let loginLinkSentToYou: String = NSLocalizedString("stytch.aiLoginLinkSentAt", value: "A login link was sent to you at ", comment: "")
    static let loginWithoutPW: String = NSLocalizedString("stytch.aiLoginWithoutPW", value: "Login without a password", comment: "")
    static let period: String = NSLocalizedString("stytch.aiPeriod", value: ".", comment: "")
}
