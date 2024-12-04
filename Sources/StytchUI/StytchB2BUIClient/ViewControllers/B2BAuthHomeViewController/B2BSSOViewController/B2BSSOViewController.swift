import AuthenticationServices
import StytchCore
import UIKit

protocol B2BSSOViewControllerDelegate: AnyObject {
    func ssoDidAuthenticatie()
}

final class B2BSSOViewController: BaseViewController<SSOState, SSOViewModel> {
    weak var delegate: B2BSSOViewControllerDelegate?
    let ssoActiveConnections: [StytchB2BClient.SSOActiveConnection]

    init(state: SSOState, delegate: B2BSSOViewControllerDelegate?, ssoActiveConnections: [StytchB2BClient.SSOActiveConnection]) {
        self.ssoActiveConnections = ssoActiveConnections
        self.delegate = delegate
        super.init(viewModel: SSOViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        view.layoutMargins = .zero

        ssoActiveConnections.enumerated().forEach { index, ssoActiveConnection in
            let button = Self.makeSSOButton(ssoActiveConnection: ssoActiveConnection)
            button.tag = index
            button.addTarget(self, action: #selector(didTapSSOButton(sender:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
    }

    @objc private func didTapSSOButton(sender: UIControl) {
        guard let (_, ssoActiveConnection) = ssoActiveConnections.enumerated().first(where: { $0.offset == sender.tag }) else {
            return
        }

        Task {
            do {
                try await viewModel.startSSO(connectionId: ssoActiveConnection.connectionId)
                delegate?.ssoDidAuthenticatie()
            } catch {
                try? await EventsClient.logEvent(parameters: .init(eventName: "ui_authentication_failure", error: error))
                presentAlert(error: error)
            }
        }
    }
}

extension B2BSSOViewController {
    static func makeSSOButton(ssoActiveConnection: StytchB2BClient.SSOActiveConnection) -> UIControl {
        let button = Button.secondary(
            image: nil,
            title: .localizedStringWithFormat(
                NSLocalizedString("stytch.ssoButtonTitle", value: "Continue with %@", comment: ""),
                ssoActiveConnection.displayName
            )
        ) {}
        button.removeTarget(nil, action: nil, for: .touchUpInside)
        return button
    }
}
