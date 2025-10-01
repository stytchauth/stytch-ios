import Combine
import StytchCore
import UIKit

final class OrganizationViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()
    var cancellable: AnyCancellable?

    lazy var getButton: UIButton = .init(title: "Get", primaryAction: .init { [weak self] _ in
        self?.get()
    })

    lazy var getSyncButton: UIButton = .init(title: "Get Sync", primaryAction: .init { [weak self] _ in
        self?.getSync()
    })

    lazy var deleteButton: UIButton = .init(title: "Delete", primaryAction: .init { [weak self] _ in
        self?.delete()
    })

    lazy var updateButton: UIButton = .init(title: "Update", primaryAction: .init { [weak self] _ in
        self?.update()
    })

    lazy var membersButton: UIButton = .init(title: "Members", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(OrganizationMemberViewController(), animated: true)
    })

    lazy var searchMembersButton: UIButton = .init(title: "Search Members", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(OrganizationMemberSearchViewController(), animated: true)
    })

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Organization"

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
        stackView.addArrangedSubview(deleteButton)
        stackView.addArrangedSubview(updateButton)
        stackView.addArrangedSubview(membersButton)
        stackView.addArrangedSubview(searchMembersButton)

        setUpOrganizationChangeListener()
    }

    func setUpOrganizationChangeListener() {
        cancellable = StytchB2BClient.organizations.onOrganizationChange
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { organizationInfo in
                switch organizationInfo {
                case let .available(organization, lastValidatedAtDate):
                    print("OrganizationChangeListener Updated Organization: \(organization.name) - \(lastValidatedAtDate)")
                case .unavailable:
                    break
                }
            }
    }

    func get() {
        Task {
            do {
                let response = try await StytchB2BClient.organizations.get()
                presentAlertAndLogMessage(description: "get organization success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "get organization error", object: error)
            }
        }
    }

    func getSync() {
        if let organization = StytchB2BClient.organizations.getSync() {
            presentAlertAndLogMessage(description: "getSyncAction organization", object: organization)
        } else {
            presentAlertWithTitle(alertTitle: "getSyncAction organization nil must get org from remote first")
        }
    }

    func delete() {
        Task {
            do {
                let response = try await StytchB2BClient.organizations.delete()
                UserDefaults.standard.set(nil, forKey: orgIdDefaultsKey)
                presentAlertAndLogMessage(description: "delete organization success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "delete organization error", object: error)
            }
        }
    }

    func update() {
        Task {
            do {
                let parameters = StytchB2BClient.Organizations.UpdateParameters(
                    organizationName: "Update Org Name Foo Bar",
                    organizationSlug: "SOMENEWSLUG",
                    organizationLogoUrl: "http://www.foobar.com/image.jpg",
                    ssoDefaultConnectionId: nil,
                    ssoJitProvisioning: .allAllowed,
                    ssoJitProvisioningAllowedConnections: [],
                    emailAllowedDomains: [],
                    emailJitProvisioning: .notAllowed,
                    emailInvites: .allAllowed,
                    authMethods: .allAllowed,
                    allowedAuthMethods: [.googleOAuth, .password],
                    mfaMethods: .allAllowed,
                    allowedMfaMethods: [.sms],
                    mfaPolicy: .optional,
                    rbacEmailImplicitRoleAssignments: nil
                )
                let response = try await StytchB2BClient.organizations.update(updateParameters: parameters)
                presentAlertAndLogMessage(description: "update organization success", object: response)
            } catch {
                presentAlertAndLogMessage(description: "update organization error", object: error)
            }
        }
    }
}
