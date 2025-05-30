import UIKit

final class EmailConfirmationViewController: BaseViewController<EmailConfirmationState, EmailConfirmationViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .IBMPlexSansRegular(size: 18)
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
        button.titleLabel?.font = .IBMPlexSansMedium(size: 18)
        button.titleLabel?.numberOfLines = 0
        return button
    }()

    init(state: EmailConfirmationState) {
        super.init(viewModel: EmailConfirmationViewModel(state: state))
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
            title: LocalizationManager.stytch_b2c_email_confirmation_alert_title,
            message: LocalizationManager.stytch_b2c_email_confirmation_alert_message(email: viewModel.state.email),
            preferredStyle: .alert
        )
        controller.addAction(.init(title: LocalizationManager.stytch_b2c_email_confirmation_alert_cancel, style: .default))
        controller.addAction(.init(title: LocalizationManager.stytch_b2c_email_confirmation_alert_confirm, style: .default) { [weak self] _ in
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
        case let .didTapCreatePassword(email: email):
            Task {
                do {
                    try await self.viewModel.forgotPassword(email: email)
                    DispatchQueue.main.async {
                        self.launchForgotPassword(email: email)
                    }
                } catch {
                    ErrorPublisher.publishError(error)
                    presentErrorAlert(error: error)
                }
            }
        case let .didTapLoginWithoutPassword(email: email):
            Task {
                do {
                    try await self.viewModel.loginWithoutPassword(email: email)
                    DispatchQueue.main.async {
                        self.launchCheckYourEmail(email: email)
                    }
                } catch {
                    ErrorPublisher.publishError(error)
                    presentErrorAlert(error: error)
                }
            }
        }
    }

    private func attrStrings(state: EmailConfirmationState) -> (info: NSAttributedString, action: NSAttributedString) {
        let transformer: ([AttrStringComponent]) -> NSAttributedString = { components in
            components.reduce(into: NSMutableAttributedString(string: "")) { partial, next in
                switch next {
                case let .bold(.string(string)):
                    partial.append(.init(string: string, attributes: [.font: UIFont.IBMPlexSansSemiBold(size: 16)]))
                case let .string(string):
                    partial.append(.init(string: string, attributes: [.font: UIFont.IBMPlexSansRegular(size: 16)]))
                default:
                    break
                }
            }
        }
        return (info: transformer(state.infoComponents), action: transformer(state.actionComponents))
    }
}

protocol EmailConfirmationViewModelDelegate: AnyObject {
    func launchCheckYourEmail(email: String)
    func launchForgotPassword(email: String)
}

extension EmailConfirmationViewController: EmailConfirmationViewModelDelegate {
    func launchCheckYourEmail(email: String) {
        let controller = EmailConfirmationViewController(
            state: .checkYourEmail(config: viewModel.state.config, email: email) {
                try await self.viewModel.loginWithoutPassword(email: email)
            }
        )
        navigationController?.pushViewController(controller, animated: true)
    }

    func launchForgotPassword(email: String) {
        let controller = EmailConfirmationViewController(
            state: .forgotPassword(config: viewModel.state.config, email: email) {
                try await self.viewModel.forgotPassword(email: email)
            }
        )
        navigationController?.pushViewController(controller, animated: true)
    }
}
