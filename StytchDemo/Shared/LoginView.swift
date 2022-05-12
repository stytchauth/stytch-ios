import StytchCore
import SwiftUI

struct LoginView: View {
    let hostUrl: URL

    @State private var email: String = ""
    @State private var isLoading = false
    @State private var checkEmailPresented = false

    var body: some View {
        VStack {
            TextField(text: $email, label: { Text("Email") })
                .onSubmit(login)
                .padding()
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
            #if !os(macOS)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
            #endif

            Button(action: login, label: {
                if isLoading {
                    ZStack {
                        ProgressView()
                            .progressViewStyle(.circular)
                        Text("Log in").hidden()
                    }
                } else {
                    Text("Log in")
                }
            })
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || email.isEmpty)
            .padding()
        }
        .alert("🪄 Check your email to finish logging in. 🪄", isPresented: $checkEmailPresented, actions: { EmptyView() })
    }

    func login() {
        isLoading = true
        Task {
            let emailParams: StytchClient.MagicLinks.Email.Parameters = .init(
                email: email,
                loginMagicLinkUrl: hostUrl.appendingPathComponent("login"),
                signupMagicLinkUrl: hostUrl.appendingPathComponent("signup"),
                loginExpiration: 10,
                signupExpiration: 10
            )
            do {
                _ = try await StytchClient.magicLinks.email.loginOrCreate(parameters: emailParams)
                checkEmailPresented = true
            } catch {
                print(error)
            }
            isLoading = false
        }
    }
}
