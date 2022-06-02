import StytchCore
import SwiftUI

struct EmailAuthenticationView: View {
    @State private var email: String = ""
    @State private var isLoading = false
    @State private var checkEmailPresented = false

    @Environment(\.openURL) var openUrl

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
        .alert("🪄 Check your email to finish logging in. 🪄", isPresented: $checkEmailPresented, actions: {
            Button("Open Gmail") {
                openUrl(URL(string: "https://mail.google.com")!)
            }
            Button("OK") { }
        })
    }

    func login() {
        isLoading = true
        Task {
            do {
                _ = try await StytchClient.magicLinks.email.loginOrCreate(parameters: .init(email: email))
                checkEmailPresented = true
            } catch {
                print(error)
            }
            isLoading = false
        }
    }
}
