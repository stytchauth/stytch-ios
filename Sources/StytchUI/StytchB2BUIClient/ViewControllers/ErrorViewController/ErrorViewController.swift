import AuthenticationServices
import StytchCore
import UIKit

final class ErrorViewController: BaseViewController<ErrorState, ErrorViewModel> {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "error", in: .module, compatibleWith: nil)
        return imageView
    }()

    init(state: ErrorState) {
        super.init(viewModel: ErrorViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        stackView.spacing = .spacingRegular

        let titleLabel = UILabel.makeTitleLabel(text: viewModel.title)
        let subtitleLabel = UILabel.makeSubtitleLabel(text: viewModel.subtitle)

        titleLabel.textAlignment = .center
        subtitleLabel.textAlignment = .center

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(SpacerView())

        configureViewForScrollView()

        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            subtitleLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalToConstant: 300),
        ])

        if viewModel.state.type == .noOrganziationFound {
            hideBackButton()
        }
    }
}
