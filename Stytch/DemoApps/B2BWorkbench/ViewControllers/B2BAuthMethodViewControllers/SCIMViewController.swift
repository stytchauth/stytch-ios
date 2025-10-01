import StytchCore
import UIKit

final class SCIMViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()

    lazy var createConnectionButton: UIButton = .init(title: "Create Connection", primaryAction: .init { [weak self] _ in
        self?.createConnection()
    })

    lazy var updateConnectionButton: UIButton = .init(title: "Update Connection", primaryAction: .init { [weak self] _ in
        self?.updateConnection()
    })

    lazy var deleteConnectionButton: UIButton = .init(title: "Delete Connection", primaryAction: .init { [weak self] _ in
        self?.deleteConnection()
    })

    lazy var getConnectionButton: UIButton = .init(title: "Get Connection", primaryAction: .init { [weak self] _ in
        self?.getConnection()
    })

    lazy var getConnectionGroupsButton: UIButton = .init(title: "Get Connection Groups", primaryAction: .init { [weak self] _ in
        self?.getConnectionGroups()
    })

    lazy var rotateStartButton: UIButton = .init(title: "Rotate Start", primaryAction: .init { [weak self] _ in
        self?.rotateStart()
    })

    lazy var rotateCompleteButton: UIButton = .init(title: "Rotate Complete", primaryAction: .init { [weak self] _ in
        self?.rotateComplete()
    })

    lazy var rotateCancelButton: UIButton = .init(title: "Rotate Cancel", primaryAction: .init { [weak self] _ in
        self?.rotateCancel()
    })

    var connectionId: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SCIM"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(createConnectionButton)
        stackView.addArrangedSubview(updateConnectionButton)
        stackView.addArrangedSubview(deleteConnectionButton)
        stackView.addArrangedSubview(getConnectionButton)
        stackView.addArrangedSubview(getConnectionGroupsButton)
        stackView.addArrangedSubview(rotateStartButton)
        stackView.addArrangedSubview(rotateCompleteButton)
        stackView.addArrangedSubview(rotateCancelButton)
    }

    func createConnection() {
        let parameters = StytchB2BClient.SCIM.CreateConnectionParameters(displayName: "A New SCIM Connection!", identityProvider: nil)
        Task {
            do {
                let response = try await StytchB2BClient.scim.createConnection(parameters: parameters)
                self.connectionId = response.wrapped.connection.connectionId
                presentAlertAndLogMessage(description: "create connection success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "create connection error", object: error)
            }
        }
    }

    func updateConnection() {
        let parameters = StytchB2BClient.SCIM.UpdateConnectionParameters(
            connectionId: connectionId,
            displayName: "A Updated SCIM Connection!",
            identityProvider: nil,
            scimGroupImplicitRoleAssignments: nil
        )
        Task {
            do {
                let response = try await StytchB2BClient.scim.updateConnection(parameters: parameters)
                self.connectionId = response.wrapped.connection.connectionId
                presentAlertAndLogMessage(description: "update connection success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "update connection error", object: error)
            }
        }
    }

    func deleteConnection() {
        Task {
            do {
                let response = try await StytchB2BClient.scim.deleteConnection(connectionId: connectionId)
                presentAlertAndLogMessage(description: "delete connection success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "delete connection error", object: error)
            }
        }
    }

    func getConnection() {
        Task {
            do {
                let response = try await StytchB2BClient.scim.getConnection()
                self.connectionId = response.wrapped.connection.connectionId
                presentAlertAndLogMessage(description: "get connection success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "get connection error", object: error)
            }
        }
    }

    func getConnectionGroups() {
        let parameters = StytchB2BClient.SCIM.GetConnectionGroupsParameters(limit: nil, cursor: nil)
        Task {
            do {
                let response = try await StytchB2BClient.scim.getConnectionGroups(parameters: parameters)
                presentAlertAndLogMessage(description: "get connection groups success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "get connection groups error", object: error)
            }
        }
    }

    func rotateStart() {
        let parameters = StytchB2BClient.SCIM.RotateParameters(connectionId: connectionId)
        Task {
            do {
                let response = try await StytchB2BClient.scim.rotateStart(parameters: parameters)
                self.connectionId = response.wrapped.connection.connectionId
                presentAlertAndLogMessage(description: "rotate start success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "rotate start error", object: error)
            }
        }
    }

    func rotateComplete() {
        let parameters = StytchB2BClient.SCIM.RotateParameters(connectionId: connectionId)
        Task {
            do {
                let response = try await StytchB2BClient.scim.rotateComplete(parameters: parameters)
                self.connectionId = response.wrapped.connection.connectionId
                presentAlertAndLogMessage(description: "rotate complete success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "rotate complete error", object: error)
            }
        }
    }

    func rotateCancel() {
        let parameters = StytchB2BClient.SCIM.RotateParameters(connectionId: connectionId)
        Task {
            do {
                let response = try await StytchB2BClient.scim.rotateCancel(parameters: parameters)
                self.connectionId = response.wrapped.connection.connectionId
                presentAlertAndLogMessage(description: "rotate cancel success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "rotate cancel error", object: error)
            }
        }
    }
}
