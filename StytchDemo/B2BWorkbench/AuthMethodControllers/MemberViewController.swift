import Combine
import StytchCore
import UIKit

final class MemberViewController: UIViewController {
    private var cancellable: AnyCancellable?

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

    private lazy var nameTextField: UITextField = {
        let textField: UITextField = .init(frame: .zero, primaryAction: updateAction)
        textField.borderStyle = .roundedRect
        textField.placeholder = "Name"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .default
        return textField
    }()

    private lazy var updateButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Update"
        return .init(configuration: configuration, primaryAction: updateAction)
    }()

    private lazy var deletePasswordButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Delete Password"
        return .init(configuration: configuration, primaryAction: deletePasswordAction)
    }()

    private lazy var deletePhoneNumberButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Delete Phone Number"
        return .init(configuration: configuration, primaryAction: deletePhoneNumberAction)
    }()

    private lazy var deleteTOTPButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Delete TOTP"
        return .init(configuration: configuration, primaryAction: deleteTOTPAction)
    }()

    private lazy var getAction: UIAction = .init { _ in
        Task {
            do {
                let resp = try await StytchB2BClient.member.get()
                print(resp)
            } catch {
                print("get member error: \(error.errorInfo)")
            }
        }
    }

    private lazy var getSyncAction: UIAction = .init { _ in
        if let member = StytchB2BClient.member.getSync() {
            print("getSync member: \(member.name)")
        } else {
            print("getSync member is nil")
        }
    }

    private lazy var updateAction: UIAction = .init { _ in
        self.update()
    }

    private lazy var deletePasswordAction: UIAction = .init { _ in

        guard let passwordId = StytchB2BClient.member.getSync()?.memberPasswordId else {
            return
        }

        Task {
            do {
                let response = try await StytchB2BClient.member.deleteFactor(.password(passwordId: passwordId))
            } catch {
                print("delete password error \(error.errorInfo)")
            }
        }
    }

    private lazy var deletePhoneNumberAction: UIAction = .init { _ in
        Task {
            do {
                let response = try await StytchB2BClient.member.deleteFactor(.phoneNumber)
            } catch {
                print("delete phone number error \(error.errorInfo)")
            }
        }
    }

    private lazy var deleteTOTPAction: UIAction = .init { _ in
        Task {
            do {
                let response = try await StytchB2BClient.member.deleteFactor(.totp)
            } catch {
                print("delete totp error \(error.errorInfo)")
            }
        }
    }

    private func update() {
        guard let name = nameTextField.text, !name.isEmpty else { return }

        Task {
            do {
                let parameters = StytchB2BClient.Members.UpdateParameters(name: name)
                let response = try await StytchB2BClient.member.update(parameters: parameters)
                presentAlertWithTitle(alertTitle: "Member Updated!")
            } catch {
                presentErrorWithDescription(error: error, description: "update member")
            }
        }
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
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(updateButton)
        stackView.addArrangedSubview(deletePasswordButton)
        stackView.addArrangedSubview(deletePhoneNumberButton)
        stackView.addArrangedSubview(deleteTOTPButton)

        setUpMemberChangeListener()
    }

    func setUpMemberChangeListener() {
        cancellable = StytchB2BClient.member.onMemberChange
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { member in
                print("MemberChangeListener Updated Member: \(member.name)")
            }
    }
}
