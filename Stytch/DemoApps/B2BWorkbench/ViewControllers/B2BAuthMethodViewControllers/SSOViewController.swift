import StytchCore
import UIKit

let ssoConnectionIdDefaultsKey = "ssoConnectionIdDefaultsKey"
let ssoRedirectURLDefaultsKey = "ssoRedirectURLDefaultsKey"

final class SSOViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()

    lazy var connectionIdTextField: UITextField = .init(title: "Connection Id", primaryAction: startAction)

    lazy var redirectUrlTextField: UITextField = .init(title: "Redirect URL", primaryAction: startAction, keyboardType: .URL)

    lazy var startButton: UIButton = .init(title: "Start", primaryAction: startAction)

    lazy var getConnectionsButton: UIButton = .init(title: "Get Connections", primaryAction: .init { [weak self] _ in
        self?.getConnections()
    })

    lazy var deleteConnectionButton: UIButton = .init(title: "Delete Connection", primaryAction: .init { [weak self] _ in
        self?.deleteConnection()
    })

    lazy var createOIDCConnectionButton: UIButton = .init(title: "Create OIDC Connection", primaryAction: .init { [weak self] _ in
        self?.createOIDCConnection()
    })

    lazy var updateOIDCConnectionButton: UIButton = .init(title: "Update OIDC Connection", primaryAction: .init { [weak self] _ in
        self?.updateOIDCConnection()
    })

    lazy var createSAMLConnectionButton: UIButton = .init(title: "Create SAML Connection", primaryAction: .init { [weak self] _ in
        self?.createSAMLConnection()
    })

    lazy var updateSAMLConnectionButton: UIButton = .init(title: "Update SAML Connection", primaryAction: .init { [weak self] _ in
        self?.updateSAMLConnection()
    })

    lazy var updateSAMLConnectionByURLButton: UIButton = .init(title: "Update SAML Connection By URL", primaryAction: .init { [weak self] _ in
        self?.updateSAMLConnection()
    })

    lazy var deleteSAMLVerificationCertificateButton: UIButton = .init(title: "Delete SAML Verification Certificate", primaryAction: .init { [weak self] _ in
        self?.deleteSAMLVerificationCertificate()
    })

    lazy var startAction: UIAction = .init { [weak self] _ in
        self?.start()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SSO"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(connectionIdTextField)
        stackView.addArrangedSubview(redirectUrlTextField)
        stackView.addArrangedSubview(startButton)
        stackView.addArrangedSubview(getConnectionsButton)
        stackView.addArrangedSubview(deleteConnectionButton)
        stackView.addArrangedSubview(createOIDCConnectionButton)
        stackView.addArrangedSubview(updateOIDCConnectionButton)
        stackView.addArrangedSubview(createSAMLConnectionButton)
        stackView.addArrangedSubview(updateSAMLConnectionButton)
        stackView.addArrangedSubview(updateSAMLConnectionByURLButton)
        stackView.addArrangedSubview(deleteSAMLVerificationCertificateButton)

        redirectUrlTextField.text = UserDefaults.standard.string(forKey: ssoRedirectURLDefaultsKey)
        connectionIdTextField.text = UserDefaults.standard.string(forKey: ssoConnectionIdDefaultsKey)

        connectionIdTextField.delegate = self
        redirectUrlTextField.delegate = self
    }

    func start() {
        guard let connectionId = connectionIdTextField.text, !connectionId.isEmpty else { return }
        guard let redirectUrlString = redirectUrlTextField.text else { return }

        UserDefaults.standard.set(redirectUrlString, forKey: ssoRedirectURLDefaultsKey)
        UserDefaults.standard.set(connectionId, forKey: ssoConnectionIdDefaultsKey)

        guard let redirectUrl = URL(string: redirectUrlString) else {
            return
        }

        Task {
            do {
                let (token, _) = try await StytchB2BClient.sso.start(
                    configuration: .init(
                        connectionId: connectionId,
                        loginRedirectUrl: redirectUrl,
                        signupRedirectUrl: redirectUrl
                    )
                )
                let response = try await StytchB2BClient.sso.authenticate(parameters: .init(ssoToken: token, locale: .en))
                presentAlertAndLogMessage(description: "sso start-authenticate success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "sso start-authenticate error", object: error)
            }
        }
    }

    func getConnections() {
        Task {
            do {
                let response = try await StytchB2BClient.sso.getConnections()
                presentAlertAndLogMessage(description: "sso get connections success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "sso get connections error", object: error)
            }
        }
    }

    func deleteConnection() {
        guard let connectionId = connectionIdTextField.text, !connectionId.isEmpty else { return }
        Task {
            do {
                let response = try await StytchB2BClient.sso.deleteConnection(connectionId: connectionId)
                presentAlertAndLogMessage(description: "sso delete connection success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "sso delete connection error", object: error)
            }
        }
    }

    func createOIDCConnection() {
        Task {
            do {
                guard let displayName = try await presentTextFieldAlertWithTitle(alertTitle: "Enter Display Name") else {
                    throw TextFieldAlertError.emptyString
                }

                guard let identityProvider = try await presentTextFieldAlertWithTitle(alertTitle: "Enter Identity Provider") else {
                    throw TextFieldAlertError.emptyString
                }

                let parameters = StytchB2BClient.SSO.OIDC.CreateConnectionParameters(displayName: displayName, identityProvider: identityProvider)
                let response = try await StytchB2BClient.sso.oidc.createConnection(parameters: parameters)
                presentAlertAndLogMessage(description: "sso create oidc connection success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "sso create oidc connection error", object: error)
            }
        }
    }

    func updateOIDCConnection() {
        guard let connectionId = connectionIdTextField.text, !connectionId.isEmpty else { return }
        Task {
            do {
                let parameters = StytchB2BClient.SSO.OIDC.UpdateConnectionParameters(
                    connectionId: connectionId,
                    displayName: nil,
                    issuer: nil,
                    clientId: nil,
                    clientSecret: nil,
                    authorizationUrl: nil,
                    tokenUrl: nil,
                    userinfoUrl: nil,
                    jwksUrl: nil,
                    identityProvider: nil
                )
                let response = try await StytchB2BClient.sso.oidc.updateConnection(parameters: parameters)
                presentAlertAndLogMessage(description: "sso update oidc connection success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "sso update oidc connection error", object: error)
            }
        }
    }

    func createSAMLConnection() {
        Task {
            do {
                guard let displayName = try await presentTextFieldAlertWithTitle(alertTitle: "Enter Display Name") else {
                    throw TextFieldAlertError.emptyString
                }

                guard let identityProvider = try await presentTextFieldAlertWithTitle(alertTitle: "Enter Identity Provider") else {
                    throw TextFieldAlertError.emptyString
                }

                let parameters = StytchB2BClient.SSO.SAML.CreateConnectionParameters(displayName: displayName, identityProvider: identityProvider)
                let response = try await StytchB2BClient.sso.saml.createConnection(parameters: parameters)
                presentAlertAndLogMessage(description: "sso create saml connection success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "sso create saml connection error", object: error)
            }
        }
    }

    func updateSAMLConnection() {
        guard let connectionId = connectionIdTextField.text, !connectionId.isEmpty else { return }
        Task {
            do {
                let parameters = StytchB2BClient.SSO.SAML.UpdateConnectionParameters(
                    connectionId: connectionId,
                    idpEntityId: nil,
                    displayName: nil,
                    attributeMapping: nil,
                    idpSsoUrl: nil,
                    x509Certificate: nil,
                    samlConnectionImplicitRoleAssignment: nil,
                    samlGroupImplicitRoleAssignment: nil,
                    identityProvider: nil
                )
                let response = try await StytchB2BClient.sso.saml.updateConnection(parameters: parameters)
                presentAlertAndLogMessage(description: "sso update saml connection success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "sso update saml connection error", object: error)
            }
        }
    }

    func updateSAMLConnectionByURL() {
        guard let connectionId = connectionIdTextField.text, !connectionId.isEmpty else { return }
        Task {
            do {
                let text = try await presentTextFieldAlertWithTitle(alertTitle: "Enter Metadata Url")
                guard text != nil else {
                    throw TextFieldAlertError.emptyString
                }

                let parameters = StytchB2BClient.SSO.SAML.UpdateConnectionByURLParameters(connectionId: connectionId, metadataUrl: "")
                let response = try await StytchB2BClient.sso.saml.updateConnectionByURL(parameters: parameters)
                presentAlertAndLogMessage(description: "sso update saml connection by url success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "sso update saml connection by url error", object: error)
            }
        }
    }

    func deleteSAMLVerificationCertificate() {
        guard let connectionId = connectionIdTextField.text, !connectionId.isEmpty else { return }
        Task {
            do {
                guard let text = try await presentTextFieldAlertWithTitle(alertTitle: "Enter Certificate ID") else {
                    throw TextFieldAlertError.emptyString
                }

                let parameters = StytchB2BClient.SSO.SAML.DeleteVerificationCertificateParameters(connectionId: connectionId, certificateId: text)
                let response = try await StytchB2BClient.sso.saml.deleteVerificationCertificate(parameters: parameters)
                presentAlertAndLogMessage(description: "sso delete saml verification certificate success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "sso delete saml verification certificate error", object: error)
            }
        }
    }
}

extension SSOViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
