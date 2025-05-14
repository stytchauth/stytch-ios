import AuthenticationServices
import StytchCore
import UIKit

protocol BiometricsRegistrationViewControllerDelegate: AnyObject {
    func biometricsRegistrationViewControllerDidComplete()
}

final class BiometricsRegistrationViewController: BaseViewController<BiometricsRegistrationState, BiometricsRegistrationViewModel> {
    weak var delegate: BiometricsRegistrationViewControllerDelegate?

    init(state: BiometricsRegistrationState, delegate: BiometricsRegistrationViewControllerDelegate) {
        super.init(viewModel: BiometricsRegistrationViewModel(state: state))
        self.delegate = delegate
    }

    override func configureView() {
        super.configureView()

        attachStackView(within: view)

        let titleLabel: UILabel = .makeTitleLabel(text: titleText)
        let subtitleLabel: UILabel = .makeSubtitleLabel(text: subtitleText)

        let enableFaceIDButton: Button = .primary(title: enableFaceIDButtonText) { [weak self] in
            self?.enableFaceIDButtonTapped()
        }

        let skipForNowButton: Button = .tertiary(title: "Skip for now") { [weak self] in
            self?.skipForNowButtonTapped()
        }

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(enableFaceIDButton)
        stackView.addArrangedSubview(skipForNowButton)
        stackView.addArrangedSubview(SpacerView())

        stackView.spacing = .spacingHuge
        stackView.setCustomSpacing(8, after: enableFaceIDButton)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        hideBackButton()
    }

    @objc func enableFaceIDButtonTapped() {
        registerBiometrics()
    }

    @objc func skipForNowButtonTapped() {
        delegate?.biometricsRegistrationViewControllerDidComplete()
    }

    func registerBiometrics() {
        StytchUIClient.startLoading()
        Task {
            do {
                let user = try await StytchClient.user.get()
                let biometricsRegistrationIdentifier = user.biometricsRegistrationIdentifier
                _ = try await StytchClient.biometrics.register(parameters: .init(identifier: biometricsRegistrationIdentifier))
                delegate?.biometricsRegistrationViewControllerDidComplete()
                StytchUIClient.stopLoading()
            } catch {
                print(error.errorInfo)
                StytchUIClient.stopLoading()
            }
        }
    }
}

extension BiometricsRegistrationViewController {
    var titleText: String {
        var titleText = "Enable Face ID login?"
        if StytchClient.biometrics.biometryType == .touchID {
            titleText = "Enable Touch ID login?"
        }
        return titleText
    }

    var subtitleText: String {
        var subtitleText = "Use Face ID to log into your account. You will be prompted to allow this app to use Face ID."
        if StytchClient.biometrics.biometryType == .touchID {
            subtitleText = "Use Touch ID to log into your account. You will be prompted to allow this app to use Touch ID."
        }
        return subtitleText
    }

    var enableFaceIDButtonText: String {
        var enableFaceIDButtonText = "Enable Face ID"
        if StytchClient.biometrics.biometryType == .touchID {
            enableFaceIDButtonText = "Enable Touch ID"
        }
        return enableFaceIDButtonText
    }
}

private extension User {
    var biometricsRegistrationIdentifier: String {
        if let email = emails.first?.email {
            return email
        } else if let phone = phoneNumbers.first?.phoneNumber {
            return phone
        } else {
            return id.rawValue
        }
    }
}
