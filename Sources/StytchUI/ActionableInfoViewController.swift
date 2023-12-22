import UIKit

final class ActionableInfoViewController: BaseViewController<ActionableInfoState, ActionableInfoViewModel> {
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

    init(state: ActionableInfoState) {
        super.init(viewModel: ActionableInfoViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

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

        titleLabel.text = viewModel.state.title
        let (info, action) = attrStrings(state: viewModel.state)
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
        switch action {
        case .didTapCreatePassword(email: let email):
            Task {
                do {
                    try await self.viewModel.forgotPassword(email: email)
                    DispatchQueue.main.async {
                        self.launchForgotPassword(email: email)
                    }
                } catch {}
            }
        case .didTapLoginWithoutPassword(email: let email):
            Task {
                do {
                    try await self.viewModel.loginWithoutPassword(email: email)
                    DispatchQueue.main.async {
                        self.launchCheckYourEmail(email: email)
                    }
                } catch {}
            }
        }
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

protocol ActionableInfoViewModelDelegate {
    func launchCheckYourEmail(email: String)
    func launchForgotPassword(email: String)
}

extension ActionableInfoViewController: ActionableInfoViewModelDelegate {
    func launchCheckYourEmail(email: String) {
        let controller = ActionableInfoViewController(
            state: .checkYourEmail(config: viewModel.state.config, email: email, retryAction: {
                Task {
                    do {
                        try await self.viewModel.loginWithoutPassword(email: email)
                        DispatchQueue.main.async {
                            self.launchCheckYourEmail(email: email)
                        }
                    } catch {}
                }
            })
        )
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func launchForgotPassword(email: String) {
        let controller = ActionableInfoViewController(
            state: .forgotPassword(config: viewModel.state.config, email: email, retryAction: {
                Task {
                    do {
                        try await self.viewModel.forgotPassword(email: email)
                        DispatchQueue.main.async {
                            self.launchForgotPassword(email: email)
                        }
                    } catch {}
                }
            })
        )
        navigationController?.pushViewController(controller, animated: true)
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
