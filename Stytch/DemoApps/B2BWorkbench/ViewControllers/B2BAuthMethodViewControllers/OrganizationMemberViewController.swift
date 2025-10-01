import StytchCore
import UIKit

class OrganizationMemberViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()

    lazy var memberIdTextField: UITextField = .init(title: "Member ID", primaryAction: .init { _ in })

    lazy var createButton: UIButton = .init(title: "Create Member", primaryAction: .init { [weak self] _ in
        self?.create()
    })

    lazy var updateButton: UIButton = .init(title: "Update Member", primaryAction: .init { [weak self] _ in
        self?.update()
    })

    lazy var reactivateButton: UIButton = .init(title: "Reactivate Member", primaryAction: .init { [weak self] _ in
        self?.reactivate()
    })

    lazy var deleteButton: UIButton = .init(title: "Delete Member", primaryAction: .init { [weak self] _ in
        self?.delete()
    })

    lazy var deleteFactorTotpButton: UIButton = .init(title: "Delete TOTP Factor", primaryAction: .init { [weak self] _ in
        self?.deleteFactorTotp()
    })

    lazy var deleteFactorPhoneNumberButton: UIButton = .init(title: "Delete Phone Number Factor", primaryAction: .init { [weak self] _ in
        self?.deleteFactorPhoneNumber()
    })

    lazy var deleteFactorPasswordButton: UIButton = .init(title: "Delete Password Factor", primaryAction: .init { [weak self] _ in
        self?.deleteFactorPassword()
    })

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Organization Member"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(memberIdTextField)
        stackView.addArrangedSubview(createButton)
        stackView.addArrangedSubview(updateButton)
        stackView.addArrangedSubview(reactivateButton)
        stackView.addArrangedSubview(deleteButton)
        stackView.addArrangedSubview(deleteFactorTotpButton)
        stackView.addArrangedSubview(deleteFactorPhoneNumberButton)
        stackView.addArrangedSubview(deleteFactorPasswordButton)

        memberIdTextField.delegate = self
    }

    func create() {
        Task {
            do {
                guard let memberEmail = try await presentTextFieldAlertWithTitle(alertTitle: "Enter email of new member!", buttonTitle: "Create Member") else {
                    throw TextFieldAlertError.emptyString
                }

                let parameters = StytchB2BClient.Organizations.Members.CreateParameters(
                    emailAddress: memberEmail,
                    name: nil,
                    untrustedMetadata: nil,
                    createMemberAsPending: nil,
                    isBreakglass: nil,
                    mfaPhoneNumber: nil,
                    mfaEnrolled: nil,
                    roles: nil
                )
                let response = try await StytchB2BClient.organizations.members.create(parameters: parameters)
                presentAlertAndLogMessage(description: "create organization member success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "create organization member error", object: error)
            }
        }
    }

    func update() {
        guard let memberId = StytchB2BClient.member.getSync()?.id.rawValue else {
            return
        }

        Task {
            do {
                guard let memberName = try await presentTextFieldAlertWithTitle(alertTitle: "Enter new name for member!", buttonTitle: "Update Member") else {
                    throw TextFieldAlertError.emptyString
                }

                let parameters = StytchB2BClient.Organizations.Members.UpdateParameters(
                    memberId: memberId,
                    name: memberName,
                    untrustedMetadata: nil,
                    isBreakglass: nil,
                    mfaPhoneNumber: nil,
                    mfaEnrolled: nil,
                    roles: nil,
                    preserveExistingSessions: nil,
                    defaultMfaMethod: nil,
                    emailAddress: nil
                )
                let response = try await StytchB2BClient.organizations.members.update(parameters: parameters)
                presentAlertAndLogMessage(description: "update organization member success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "update organization member error", object: error)
            }
        }
    }

    func reactivate() {
        guard let memberId = memberIdTextField.text else {
            presentAlertWithTitle(alertTitle: "Fill out member id text field")
            return
        }

        Task {
            do {
                let response = try await StytchB2BClient.organizations.members.reactivate(memberId: memberId)
                presentAlertAndLogMessage(description: "reactivate organization member success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "reactivate organization member error", object: error)
            }
        }
    }

    func delete() {
        guard let memberId = memberIdTextField.text else {
            presentAlertWithTitle(alertTitle: "Fill out member id text field")
            return
        }

        Task {
            do {
                let response = try await StytchB2BClient.organizations.members.delete(memberId: memberId)
                presentAlertAndLogMessage(description: "delete organization member success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "delete organization member error", object: error)
            }
        }
    }

    func deleteFactorTotp() {
        guard let memberId = memberIdTextField.text else {
            presentAlertWithTitle(alertTitle: "Fill out member id text field")
            return
        }

        Task {
            do {
                let response = try await StytchB2BClient.organizations.members.deleteFactor(factor: .totp(memberId: memberId))
                presentAlertAndLogMessage(description: "delete factor totp from organization member success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "delete factor totp from organization member error", object: error)
            }
        }
    }

    func deleteFactorPhoneNumber() {
        guard let memberId = memberIdTextField.text else {
            presentAlertWithTitle(alertTitle: "Fill out member id text field")
            return
        }

        Task {
            do {
                let response = try await StytchB2BClient.organizations.members.deleteFactor(factor: .phoneNumber(memberId: memberId))
                presentAlertAndLogMessage(description: "delete factor phone number from organization member success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "delete factor phone number from organization member error", object: error)
            }
        }
    }

    func deleteFactorPassword() {
        // This is only for the current member, but in theory you could call this for any user's password id
        guard let passwordId = StytchB2BClient.member.getSync()?.memberPasswordId else {
            return
        }

        Task {
            do {
                let response = try await StytchB2BClient.organizations.members.deleteFactor(factor: .password(passwordId: passwordId))
                presentAlertAndLogMessage(description: "delete factor password from organization member success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "delete factor password from organization member error", object: error)
            }
        }
    }
}

extension OrganizationMemberViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
