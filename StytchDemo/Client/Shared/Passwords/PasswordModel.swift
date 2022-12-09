import StytchCore
import SwiftUI

final class PasswordModel: ObservableObject {
    @Published var email = ""
    @Published var isSecure = false
    @Published var password = ""
    @Published var strength: Double?
    @Published var warning = ""
    @Published var feedback = ""
    @Published var isValid = false

    func checkStrength() {
        Task {
            do {
                let resp = try await StytchClient.passwords.strengthCheck(
                    parameters: .init(email: email.presence, password: password)
                )
                await MainActor.run {
                    self.strength = resp.score / 4
                    self.isValid = resp.validPassword
                    self.warning = resp.feedback.warning
                    self.feedback = resp.feedback.suggestions.first ?? ""
                }
            } catch {
                print(error)
            }
        }
    }

    @discardableResult
    func resetPasswordStart() async throws -> BasicResponse {
        try await StytchClient.passwords.resetByEmailStart(
            parameters: .init(email: email, loginUrl: configuration.serverUrl, resetPasswordUrl: configuration.serverUrl)
        )
    }

    func resetPassword(token: String) async throws -> AuthenticateResponseType {
        try await StytchClient.passwords.resetByEmail(
            parameters: .init(token: token, password: password)
        )
    }

    func login() async throws -> AuthenticateResponseType {
        try await StytchClient.passwords.authenticate(
            parameters: .init(email: email, password: password)
        )
    }

    func signUp() async throws -> AuthenticateResponseType {
        try await StytchClient.passwords.create(
            parameters: .init(email: email, password: password)
        )
    }
}
