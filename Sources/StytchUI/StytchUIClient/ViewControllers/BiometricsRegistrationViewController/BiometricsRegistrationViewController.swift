import AuthenticationServices
import StytchCore
import UIKit

protocol BiometricsRegistrationViewControllerDelegate: AnyObject {
    func biometricsRegistrationViewControllerDidComplete()
}

final class BiometricsRegistrationViewController: BaseViewController<BiometricsRegistrationState, BiometricsRegistrationViewModel> {
    weak var delegate: BiometricsRegistrationViewControllerDelegate?

    private let titleLabel: UILabel = .makeTitleLabel(text: "Enable Face ID login?")

    private let subtitleLabel: UILabel = .makeSubtitleLabel(text: "Use Face ID to log into your account. You will be prompted to allow this app to use Face ID.")

    private lazy var enableFaceIDButton: Button = .primary(title: "Enable Face ID") { [weak self] in
        self?.enableFaceIDButtonTapped()
    }

    private lazy var skipForNowButton: Button = .tertiary(title: "Skip for now") { [weak self] in
        self?.skipForNowButtonTapped()
    }

    init(state: BiometricsRegistrationState) {
        super.init(viewModel: BiometricsRegistrationViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        attachStackView(within: view)

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(enableFaceIDButton)
        stackView.addArrangedSubview(skipForNowButton)
        stackView.addArrangedSubview(SpacerView())

        stackView.spacing = .spacingHuge

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
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
                let response = try await StytchClient.biometrics.register(parameters: .init(identifier: viewModel.state.identifier))
                print(response)
                delegate?.biometricsRegistrationViewControllerDidComplete()
                StytchUIClient.stopLoading()
            } catch {
                print(error.errorInfo)
                StytchUIClient.stopLoading()
            }
        }
    }
}
