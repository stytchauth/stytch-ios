import UIKit

final class ActionableInfoViewController: BaseViewController<Empty, AIVCState, AIVCAction> {
    private let titleLabel: UILabel = .makeTitleLabel()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        label.textColor = .label
        return label
    }()

    private let retryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.secondary, for: .normal)
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

        view.layoutMargins = .init(top: .verticalMargin, left: .horizontalMargin, bottom: .verticalMargin, right: .horizontalMargin)
        stackView.spacing = .spacingHuge
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(infoLabel)
        stackView.addArrangedSubview(retryButton)

        if let secondaryAction = state.secondaryAction {
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

    override func stateDidUpdate(state: State) {
        titleLabel.text = state.title
        let (info, action) = attrStrings(state: state)
        infoLabel.attributedText = info
        retryButton.setAttributedTitle(action, for: .normal)
    }

    private func attrStrings(state: AIVCState) -> (info: NSAttributedString, action: NSAttributedString) {
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

struct AIVCState {
    let title: String
    let infoComponents: [AttrStringComponent]
    let actionComponents: [AttrStringComponent]
    let secondaryAction: (title: String, action: AIVCAction)?
}

enum AIVCAction {
    case didTapCreatePassword(email: String)
    case didTapLoginWithoutPassword(email: String)
}

extension AIVCState {
    static func forgotPassword(email: String) -> Self {
        .init(
            title: NSLocalizedString("stytch.aiForgotPW", value: "Forgot password?", comment: ""),
            infoComponents: [
                .string(NSLocalizedString("stytch.linkToResetPWSent", value: "A link to reset your password was sent to you at ", comment: "")),
                .bold(.string(email)),

            ],
            actionComponents: .didntGetItResendEmail,
            secondaryAction: nil
        )
    }

    static func checkYourEmail(email: String) -> Self {
        .init(
            title: .checkEmail,
            infoComponents: [.string(.loginLinkSentToYou), .bold(.string(email)), "."],
            actionComponents: .didntGetItResendEmail,
            secondaryAction: nil
        )
    }

    static func checkYourEmailCreatePWInstead(email: String) -> Self {
        .init(
            title: .checkEmail,
            infoComponents: [.string(.loginLinkSentToYou), .bold(.string(email)), "."],
            actionComponents: .didntGetItResendEmail,
            secondaryAction: (NSLocalizedString("stytch.aiCreatePWInstead", value: "Create a password instead", comment: ""), .didTapCreatePassword(email: email))
        )
    }

    static func checkYourEmailReset(email: String) -> Self {
        .init(
            title: .checkEmailForNewPW,
            infoComponents: [
                .string(.loginLinkSentToYou),
                .bold(.string(email)),
                .string(NSLocalizedString("stytch.toCreatePW", value: " to create a password for your account.", comment: ""))
            ],
            actionComponents: .didntGetItResendEmail,
            secondaryAction: nil
        )
    }

    // TODO: determine how to know when to show this (should be after a returning user w/ password logs in via magic link, but what tells us that password was breached). maybe in loginOrCreate response or authenticate response
    static func checkYourEmailResetReturning(email: String) -> Self {
        .init(
            title: .checkEmailForNewPW,
            infoComponents: [
                .string(NSLocalizedString("stytch.aiMakeSureAcctSecure", value: "We want to make sure your account is secure and that it’s really you logging in! A login link was sent to you at ", comment: "")),
                .bold(.string(email)),
                .string(.period)
            ],
            actionComponents: .didntGetItResendEmail,
            secondaryAction: (.loginWithoutPW, .didTapLoginWithoutPassword(email: email))
        )
    }

    static func checkYourEmailResetBreached(email: String) -> Self {
        .init(
            title: .checkEmailForNewPW,
            infoComponents: [
                .string(NSLocalizedString("stytch.aiPWBreach", value: "A different site where you use the same password had a security issue recently. For your safety, an email was sent to you at ", comment: "")),
                .bold(.string(email)),
                .string(NSLocalizedString("stytch.toResetPW", value: " to reset your password.", comment: ""))
            ],
            actionComponents: .didntGetItResendEmail,
            secondaryAction: (.loginWithoutPW, .didTapLoginWithoutPassword(email: email))
        )
    }
}

extension [AttrStringComponent] {
    static var didntGetItResendEmail: Self {
        [
            .string(NSLocalizedString("stytch.aiDidntGetIt", value: "Didn't get it? ", comment: "")),
            .bold(.string(NSLocalizedString("stytch.aiResendEmail", value: "Resend email", comment: "")))
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
