import StytchCore
import UIKit

final class MemberViewController: UIViewController {
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.layoutMargins = Constants.insets
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        view.spacing = 8
        return view
    }()

    private lazy var getButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Get"
        return .init(configuration: configuration, primaryAction: getAction)
    }()

    private lazy var getSyncButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Get Sync"
        return .init(configuration: configuration, primaryAction: getSyncAction)
    }()

    private lazy var getAction: UIAction = .init { _ in
        Task {
            do {
                let resp = try await StytchB2BClient.member.get()
                print(resp)
            } catch {
                print(error)
            }
        }
    }

    private lazy var getSyncAction: UIAction = .init { _ in
        print(StytchB2BClient.member.getSync())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Member"

        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(getButton)
        stackView.addArrangedSubview(getSyncButton)
    }
}
