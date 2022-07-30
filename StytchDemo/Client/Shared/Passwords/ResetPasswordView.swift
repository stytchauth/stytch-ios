import StytchCore
import SwiftUI

struct ResetPasswordView: View {
    let token: String
    let onAuth: (Session, User) -> Void

    @StateObject private var model = PasswordModel()

    var body: some View {
        VStack {
            PasswordView(
                title: "New Password",
                onSubmit: resetPassword,
                onDebouncedInteraction: model.checkStrength,
                isSecure: model.isSecure,
                password: $model.password,
                publisher: model.$password
            )

            PasswordFeedbackView(strength: model.strength, warning: model.warning, feedback: model.feedback)

            Button("Submit", action: resetPassword)
                .buttonStyle(.borderedProminent)
                .padding()
        }
    }

    func resetPassword() {
        Task {
            do {
                let resp = try await model.resetPassword(token: token)
                onAuth(resp.session, resp.user)
            } catch {
                print(error)
            }
        }
    }
}
