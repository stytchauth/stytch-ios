import Combine
import StytchCore
import SwiftUI

struct PasswordAuthenticationView: View {
    private var serverUrl: URL { configuration.serverUrl }
    let onAuth: (AuthenticateResponseType) -> Void

    @StateObject private var model = PasswordModel()

    @State private var authOption: AuthOption = .allCases.first!
    @State private var isLoading = false
    @State private var checkEmailPresented = false

    @Environment(\.openURL) var openUrl

    var body: some View {
        VStack {
            Picker(
                selection: $authOption,
                content: {
                    ForEach(AuthOption.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                },
                label: { Text("Delivery Method") }
            )
            .pickerStyle(.segmented)
            .padding()

            Spacer()

            Toggle("Hide Password", isOn: $model.isSecure)
                .padding(.horizontal)

            TextField(text: $model.email, label: { Text("Email") })
                .padding()
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
            #if !os(macOS)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
            #endif

            PasswordView(
                title: "Password",
                onSubmit: submit,
                onDebouncedInteraction: model.checkStrength,
                isSecure: model.isSecure,
                password: $model.password,
                publisher: model.$password
            )

            if authOption == .signUp {
                PasswordFeedbackView(strength: model.strength, warning: model.warning, feedback: model.feedback)
                Button("Reset password? \(model.email.isEmpty ? "(email required)" : "")") {
                    Task {
                        do {
                            try await model.resetPasswordStart()
                            checkEmailPresented = true
                        } catch {
                            print(error)
                        }
                    }
                }
                .disabled(model.email.isEmpty)
                .tint(.primary)
                .padding()
            }

            Spacer()

            Button(action: submit, label: {
                if isLoading {
                    ZStack {
                        ProgressView()
                            .progressViewStyle(.circular)
                        Text(authOption.rawValue).hidden()
                    }
                } else {
                    Text(authOption.rawValue)
                }
            })
            .buttonStyle(.borderedProminent)
            .disabled(
                [model.email, model.password].contains(where: \.isEmpty) ||
                    (authOption == .signUp && !model.isValid)
            )
            .padding()
        }
        .alert("Check your email", isPresented: $checkEmailPresented, actions: { EmptyView() })
    }

    func submit() {
        isLoading = true
        Task {
            do {
                switch authOption {
                case .signUp:
                    onAuth(try await model.signUp())
                case .logIn:
                    onAuth(try await model.login())
                }
            } catch {
                print(error)
            }
            isLoading = false
        }
    }

    private enum AuthOption: String, CaseIterable {
        case signUp = "Sign up"
        case logIn = "Log in"
    }
}
