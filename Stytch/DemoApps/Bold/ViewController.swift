import Combine
import StytchCore
import SwiftOTP
import UIKit

class ViewController: UIViewController {
    let email = ""
    let password = ""
    let opaqueSessionToken = "" // for hydrating the session from an external source
    let publicToken = ""

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        StytchClient.configure(configuration: .init(publicToken: publicToken))

        printTotpCode()

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        let actions: [(String, Selector)] = [
            ("Create User With All Factors", #selector(createUserWithAllFactors)),
            ("Biometrics And TOTP", #selector(biometricsAndTotp)),
            ("Password And Biometrics", #selector(passwordAndBiometrics)),
            ("Hydrate Session And Biometrics", #selector(hydrateSessionAndBiometrics)),
            ("Hydrate Session And Password", #selector(hydrateSessionAndPassword)),
            ("Log Out", #selector(logOut)),
            ("Print TOTP Code", #selector(printTotpCode)),
        ]

        for (title, selector) in actions {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: selector, for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }

        StytchClient.sessions.onSessionChange
            .receive(on: DispatchQueue.main)
            .sink { sessionInfo in
                switch sessionInfo {
                case let .available(session, lastValidatedAtDate):
                    print("Session Available: \(session.expiresAt) - lastValidatedAtDate: \(lastValidatedAtDate)\n")
                    print("hasAuthenticatedWithMultipleFactors: \(session.hasAuthenticatedWithMultipleFactors)")
                case .unavailable:
                    print("Session Unavailable\n")
                }
            }.store(in: &cancellables)
    }

    @objc func printTotpCode() {
        if let totpCode = totpCode() {
            print("totpCode: \(totpCode)")
        }
    }

    // User has the following factors: Email + password (verified email), TOTP, Biometric
    @objc func createUserWithAllFactors() {
        Task {
            do {
                try await createPasswordUser()
                try await registerBiometrics()
                try await createTOTPInstance()
                print("Successfully created user with all factors")
            } catch {
                print(error.errorInfo)
            }
        }
    }

    // User can log in via Biometric 1FA + TOTP 2FA
    @objc func biometricsAndTotp() {
        Task {
            do {
                try await autheticateBiometrics()
                let session = try await authenticateTOTP()
                print("Successfully biometricsAndTotp")
            } catch {
                print(error.errorInfo)
            }
        }
    }

    // User can log in via Password 1FA + Biometric 2FA
    @objc func passwordAndBiometrics() {
        Task {
            do {
                try await authenticateWithPassword()
                let session = try await autheticateBiometrics()
                print("Successfully passwordAndBiometrics")
            } catch {
                print(error.errorInfo)
            }
        }
    }

    // User can log in via TOTP 1FA (via backend, user ID is saved along with in-app TOTP code) + session hydrated on SDK + Biometric 2FA
    @objc func hydrateSessionAndBiometrics() {
        Task {
            do {
                try await hydrateSession()
                let session = try await autheticateBiometrics()
                print("Successfully hydrateSessionAndBiometrics")
            } catch {
                print(error.errorInfo)
            }
        }
    }

    // User can log in via TOTP 1FA (via backend, user ID is saved along with in-app TOTP code) + session hydrated on SDK + Password 2FA
    @objc func hydrateSessionAndPassword() {
        Task {
            do {
                try await hydrateSession()
                let session = try await authenticateWithPassword()
                print("Successfully hydrateSessionAndPassword")
            } catch {
                print(error.errorInfo)
            }
        }
    }

    @objc func logOut() {
        Task {
            do {
                let response = try await StytchClient.sessions.revoke(parameters: .init(forceClear: true))
                print("log out response: \(response)")
            } catch {
                print(error.errorInfo)
            }
        }
    }
}

extension ViewController {
    @discardableResult func hydrateSession() async throws -> Session {
        guard let sessionTokens = SessionTokens(jwt: nil, opaque: .opaque(opaqueSessionToken)) else {
            throw StytchSDKError.noCurrentSession
        }

        StytchClient.sessions.update(sessionTokens: sessionTokens)
        let response = try await StytchClient.sessions.authenticate(parameters: .init(sessionDurationMinutes: .defaultSessionDuration))
        return response.session
    }
}

extension ViewController {
    static let secretKey = "stytch_totp_secret"

    func saveSecret(secret: String) {
        UserDefaults.standard.set(secret, forKey: Self.secretKey)
    }

    func totpCode() -> String? {
        guard let secret = UserDefaults.standard.string(forKey: Self.secretKey),
              let dataSecret = base32DecodeToData(secret),
              let totp = TOTP(secret: dataSecret),
              let totpCode = totp.generate(time: Date())
        else {
            return nil
        }
        return totpCode
    }

    func clearSecret() {
        UserDefaults.standard.removeObject(forKey: Self.secretKey)
    }

    func createTOTPInstance() async throws {
        let response = try await StytchClient.totps.create(
            parameters: .init(
                expiration: .defaultSessionDuration
            )
        )

        saveSecret(secret: response.secret)
    }

    @discardableResult func authenticateTOTP() async throws -> Session {
        let totpCode = totpCode() ?? ""

        let response = try await StytchClient.totps.authenticate(
            parameters: .init(
                totpCode: totpCode,
                sessionDuration: .defaultSessionDuration
            )
        )

        return response.session
    }
}

extension ViewController {
    func registerBiometrics() async throws {
        let response = try await StytchClient.biometrics.register(
            parameters: .init(
                identifier: email,
                accessPolicy: .deviceOwnerAuthentication
            )
        )
        print(response.session)
    }

    @discardableResult func autheticateBiometrics() async throws -> Session {
        let response = try await StytchClient.biometrics.authenticate(
            parameters: .init(
                sessionDuration: .defaultSessionDuration
            )
        )

        return response.session
    }
}

extension ViewController {
    @discardableResult func createPasswordUser() async throws -> Session {
        let response = try await StytchClient.passwords.create(
            parameters: .init(
                email: email,
                password: password,
                sessionDurationMinutes: .defaultSessionDuration
            )
        )

        return response.session
    }

    @discardableResult func authenticateWithPassword() async throws -> Session {
        let response = try await StytchClient.passwords.authenticate(
            parameters: .init(
                email: email,
                password: password,
                sessionDurationMinutes: .defaultSessionDuration
            )
        )

        return response.session
    }
}

public extension Session {
    var hasAuthenticatedWithMultipleFactors: Bool {
        authenticationFactors.count >= 2
    }
}

public extension User {
    var isActiveUser: Bool {
        status == .active
    }

    var hasPassword: Bool {
        password != nil
    }

    var hasVerifiedEmail: Bool {
        emails.contains { $0.verified }
    }

    var hasVerifiedPhoneNumber: Bool {
        phoneNumbers.contains { $0.verified }
    }

    var hasVerifiedCryptoWallet: Bool {
        cryptoWallets.contains { $0.verified }
    }

    var hasOAuthProvider: Bool {
        !providers.isEmpty
    }

    var hasVerifiedTOTP: Bool {
        totps.contains { $0.verified }
    }

    var hasVerifiedWebAuthn: Bool {
        webauthnRegistrations.contains { $0.verified }
    }

    var hasVerifiedBiometricRegistrations: Bool {
        biometricRegistrations.contains { $0.verified }
    }

    var fullName: String? {
        let parts = [name.firstName, name.middleName, name.lastName].compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: " ")
    }
}
