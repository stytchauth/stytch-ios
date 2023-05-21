import UIKit

final class ActionableInformationViewController: BaseViewController<Empty, AIVCState, OAuthAction> {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 24, weight: .semibold) // FIXME: turn into reusable title font
        label.textColor = .label
        return label
    }()

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
        stackView.spacing = 32
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(infoLabel)
        stackView.addArrangedSubview(retryButton)

        if case let .loaded(state) = state, let secondaryAction = state.secondaryAction {
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

    override func stateDidUpdate(state: ControllerState) {
        switch state {
        case .initial, .loading:
            break
        case let .loaded(state):
            titleLabel.text = state.title
            let (info, action) = attrStrings(state: state)
            infoLabel.attributedText = info
            retryButton.setAttributedTitle(action, for: .normal)
        }
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
    let secondaryAction: (title: String, action: () -> OAuthAction)?
}

extension AIVCState {
    static func forgotPassword(email: String) -> Self {
        .init(
            title: "Forgot password?",
            infoComponents: ["A link to reset your password was sent to you at ", .bold(.string(email)), "."],
            actionComponents: .didntGetItResendEmail,
            secondaryAction: nil
        )
    }

    static func checkYourEmail(email: String) -> Self {
        .init(
            title: "Check your email",
            infoComponents: ["A login link was sent to you at ", .bold(.string(email)), "."],
            actionComponents: .didntGetItResendEmail,
            secondaryAction: nil
        )
    }

    static func checkYourEmailCreatePWInstead(email: String) -> Self {
        .init(
            title: "Check your email",
            infoComponents: ["A login link was sent to you at ", .bold(.string(email)), "."],
            actionComponents: .didntGetItResendEmail,
            secondaryAction: ("Create a password instead", { .didTap(provider: .apple) })
        )
    }

    static func checkYourEmailReset(email: String) -> Self {
        .init(
            title: "Check your email to set a new password",
            infoComponents: ["A login link was sent to you at ", .bold(.string(email)), " to create a password for your account."],
            actionComponents: .didntGetItResendEmail,
            secondaryAction: nil
        )
    }

    static func checkYourEmailResetReturning(email: String) -> Self {
        .init(
            title: "Check your email to set a new password",
            infoComponents: ["We want to make sure your account is secure and that it’s really you logging in! A login link was sent to you at ", .bold(.string(email)), "."],
            actionComponents: .didntGetItResendEmail,
            secondaryAction: ("Login without a password", { .didTap(provider: .apple) })
        )
    }

    static func checkYourEmailResetBreached(email: String) -> Self {
        .init(
            title: "Check your email to set a new password",
            infoComponents: ["A different site where you use the same password had a security issue recently. For your safety, an email was sent to you at ", .bold(.string(email)), " to reset your password."],
            actionComponents: .didntGetItResendEmail,
            secondaryAction: ("Login without a password", { .didTap(provider: .apple) })
        )
    }
}

extension [AttrStringComponent] {
    static var didntGetItResendEmail: Self {
        ["Didn't get it? ", .bold("Resend email")]
    }
}
