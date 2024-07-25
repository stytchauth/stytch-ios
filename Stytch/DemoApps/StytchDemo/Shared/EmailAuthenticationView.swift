import StytchCore
import SwiftUI

struct EmailAuthenticationView: View {
    private var serverUrl: URL { configuration.serverUrl }

    @State private var email: String = ""
    @State private var loginTemplateId: String = ""
    @State private var signupTemplateId: String = ""
    @State private var isLoading = false
    @State private var checkEmailPresented = false

    @Environment(\.openURL) private var openUrl

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .onSubmit(login)
                .padding()
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
            #if !os(macOS)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
            #endif

            TextField("Signup template ID", text: $signupTemplateId)
                .onSubmit(login)
                .padding()
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
            #if !os(macOS)
                .textInputAutocapitalization(.never)
            #endif

            TextField("Login template ID", text: $loginTemplateId)
                .onSubmit(login)
                .padding()
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
            #if !os(macOS)
                .textInputAutocapitalization(.never)
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
            Button("OK") {}
        })
    }

    func login() {
        isLoading = true
        Task {
            do {
                _ = try await StytchClient.magicLinks.email.loginOrCreate(
                    parameters: .init(
                        email: email,
                        loginMagicLinkUrl: serverUrl,
                        loginTemplateId: loginTemplateId.presence,
                        signupMagicLinkUrl: serverUrl,
                        signupTemplateId: signupTemplateId.presence
                    )
                )
                checkEmailPresented = true
            } catch {
                print(error)
            }
            isLoading = false
        }
    }
}
