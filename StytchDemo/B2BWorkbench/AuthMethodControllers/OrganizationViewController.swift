import Combine
import StytchCore
import UIKit

final class OrganizationViewController: UIViewController {
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

    private lazy var deleteButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Delete"
        return .init(configuration: configuration, primaryAction: deleteAction)
    }()

    private lazy var updateButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Update"
        return .init(configuration: configuration, primaryAction: updateAction)
    }()

    private lazy var getAction: UIAction = .init { [weak self] _ in
        self?.get()
    }

    func get() {
        Task {
            do {
                let response = try await StytchB2BClient.organizations.get()
                presentAlertWithTitle(alertTitle: "get organization response: \(response)")
            } catch {
                presentAlertWithTitle(alertTitle: "get organization error: \(error.errorInfo)")
            }
        }
    }

    private lazy var getSyncAction: UIAction = .init { [weak self] _ in
        if let organization = StytchB2BClient.organizations.getSync() {
            self?.presentAlertWithTitle(alertTitle: "getSyncAction organization: \(organization)")
        } else {
            self?.presentAlertWithTitle(alertTitle: "getSyncAction organization nil")
        }
    }

    private lazy var deleteAction: UIAction = .init { [weak self] _ in
        self?.delete()
    }

    func delete() {
        Task {
            do {
                let response = try await StytchB2BClient.organizations.delete()
                UserDefaults.standard.set(nil, forKey: Constants.orgIdDefaultsKey)
                presentAlertWithTitle(alertTitle: "delete organization response: \(response)")
            } catch {
                presentAlertWithTitle(alertTitle: "delete organization error: \(error.errorInfo)")
            }
        }
    }

    private lazy var updateAction: UIAction = .init { [weak self] _ in
        self?.update()
    }

    func update() {
        Task {
            do {
                let parameters = StytchB2BClient.Organizations.UpdateParameters(
                    organizationName: "Update Org Name Foo Bar",
                    organizationSlug: "SOMENEWSLUG",
                    organizationLogoUrl: "http://www.foobar.com/image.jpg",
                    ssoDefaultConnectionId: nil,
                    ssoJitProvisioning: .ALL_ALLOWED,
                    ssoJitProvisioningAllowedConnections: [],
                    emailAllowedDomains: [],
                    emailJitProvisioning: .NOT_ALLOWED,
                    emailInvites: .ALL_ALLOWED,
                    authMethods: .ALL_ALLOWED,
                    allowedAuthMethods: [.GOOGLE_OAUTH, .PASSWORD],
                    mfaMethods: .ALL_ALLOWED,
                    allowedMfaMethods: [.SMS],
                    mfaPolicy: .OPTIONAL,
                    rbacEmailImplicitRoleAssignments: nil
                )
                let response = try await StytchB2BClient.organizations.update(updateParameters: parameters)
                presentAlertWithTitle(alertTitle: "update organization success")
            } catch {
                presentAlertWithTitle(alertTitle: "update organization error: \(error.errorInfo)")
            }
        }
    }

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

        setUpOrganizationChangeListener()
    }

    func setUpOrganizationChangeListener() {
        cancellable = StytchB2BClient.organizations.onOrganizationChange
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { organization in
                print("OrganizationChangeListener Updated Organization: \(organization.name)")
            }
    }
}
