import Combine
import StytchCore
import UIKit

final class MemberViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()
    var cancellable: AnyCancellable?

    lazy var getButton: UIButton = .init(title: "Get", primaryAction: .init { [weak self] _ in
        self?.get()
    })

    lazy var getSyncButton: UIButton = .init(title: "Get Sync", primaryAction: .init { [weak self] _ in
        self?.getSync()
    })

    lazy var nameTextField: UITextField = .init(title: "Name", primaryAction: .init { [weak self] _ in
        self?.update()
    })

    lazy var updateButton: UIButton = .init(title: "Update", primaryAction: .init { [weak self] _ in
        self?.update()
    })

    lazy var deletePasswordButton: UIButton = .init(title: "Delete Password", primaryAction: .init { [weak self] _ in
        self?.deletePassword()
    })

    lazy var deletePhoneNumberButton: UIButton = .init(title: "Delete Phone Number", primaryAction: .init { [weak self] _ in
        self?.deletePhoneNumber()
    })

    lazy var deleteTOTPButton: UIButton = .init(title: "Delete TOTP", primaryAction: .init { [weak self] _ in
        self?.deleteTOTP()
    })

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

        nameTextField.delegate = self
    }

    func setUpMemberChangeListener() {
        cancellable = StytchB2BClient.member.onMemberChange
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { memberInfo in
                switch memberInfo {
                case let .available(member, lastValidatedAtDate):
                    print("MemberChangeListener Updated Member: \(member.name) - \(lastValidatedAtDate)")
                case .unavailable:
                    break
                }
            }
    }

    func getSync() {
        if let member = StytchB2BClient.member.getSync() {
            print("getSync member: \(member.name)")
        } else {
            print("getSync member is nil")
        }
    }

    func get() {
        Task {
            do {
                let response = try await StytchB2BClient.member.get()
                presentAlertAndLogMessage(description: "get member success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "get member error", object: error)
            }
        }
    }

    func update() {
        guard let name = nameTextField.text, !name.isEmpty else {
            return
        }

        Task {
            do {
                let parameters = StytchB2BClient.Members.UpdateParameters(
                    name: name,
                    untrustedMetadata: nil,
                    mfaEnrolled: nil,
                    mfaPhoneNumber: nil,
                    defaultMfaMethod: nil
                )
                let response = try await StytchB2BClient.member.update(parameters: parameters)
                presentAlertAndLogMessage(description: "update member success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "update member error", object: error)
            }
        }
    }

    func deletePassword() {
        guard let passwordId = StytchB2BClient.member.getSync()?.memberPasswordId else {
            return
        }

        Task {
            do {
                let response = try await StytchB2BClient.member.deleteFactor(.password(passwordId: passwordId))
                presentAlertAndLogMessage(description: "delete password success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "delete password error", object: error)
            }
        }
    }

    func deletePhoneNumber() {
        Task {
            do {
                let response = try await StytchB2BClient.member.deleteFactor(.phoneNumber)
                presentAlertAndLogMessage(description: "delete phone number success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "delete phone number error", object: error)
            }
        }
    }

    func deleteTOTP() {
        Task {
            do {
                let response = try await StytchB2BClient.member.deleteFactor(.totp)
                presentAlertAndLogMessage(description: "delete totp success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "delete totp error", object: error)
            }
        }
    }
}

extension MemberViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
