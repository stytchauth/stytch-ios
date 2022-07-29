import Combine
import StytchCore
import SwiftUI

struct PasswordAuthenticationView: View {
    private var serverUrl: URL { configuration.serverUrl }
    let onAuth: (Session, User) -> Void

    @StateObject private var model = ViewModel()

    @Environment(\.openURL) var openUrl

    var body: some View {
        VStack {
            Picker(
                selection: $model.authOption,
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
                .onSubmit(login)
                .padding()
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
            #if !os(macOS)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
            #endif

            (
                model.isSecure ?
                    AnyView(SecureField(text: $model.password, label: { Text("Password") })) :
                    AnyView(TextField(text: $model.password, label: { Text("Password") }))
            )
            .onReceive(
                model.$password
                    .removeDuplicates()
                    .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
                    .map { _ in },
                perform: {
                    guard model.authOption == .signUp else { return }
                    checkStrength()
                }
            )
            .onSubmit(model.authOption == .signUp ? signUp : login)
            .padding(.horizontal)
            .textFieldStyle(.roundedBorder)
            .disableAutocorrection(true)
            #if !os(macOS)
                .textInputAutocapitalization(.never)
                .textContentType(.password)
            #endif

            if model.authOption == .signUp {
                if let strength = model.strength {
                    ProgressView("Password Strength", value: strength)
                        .tint(strength <= 0.5 ? .red : .green)
                        .padding(.horizontal)
                }
                if !model.warning.isEmpty {
                    Text(model.warning)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                if !model.feedback.isEmpty {
                    Text(model.feedback)
                        .padding()
                }
            }

            Spacer()

            Button(action: model.authOption == .signUp ? signUp : login, label: {
                if model.isLoading {
                    ZStack {
                        ProgressView()
                            .progressViewStyle(.circular)
                        Text(model.authOption.rawValue).hidden()
                    }
                } else {
                    Text(model.authOption.rawValue)
                }
            })
            .buttonStyle(.borderedProminent)
            .disabled(model.authOption == .signUp ? !model.isValid : false)
            .padding()
        }
    }

    func login() {
        model.isLoading = true
        Task {
            do {
                let resp = try await StytchClient.passwords.authenticate(
                    parameters: .init(email: model.email, password: model.password)
                )
                onAuth(resp.session, resp.user)
            } catch {
                print(error)
            }
            model.isLoading = false
        }
    }

    func signUp() {
        model.isLoading = true
        Task {
            do {
                let resp = try await StytchClient.passwords.create(
                    parameters: .init(email: model.email, password: model.password)
                )
                onAuth(resp.session, resp.user)
            } catch {
                print(error)
            }
            model.isLoading = false
        }
    }

    func checkStrength() {
        Task {
            do {
                let resp = try await StytchClient.passwords.strengthCheck(
                    parameters: .init(email: model.email.presence, password: model.password)
                )
                model.strength = resp.score / 4
                model.isValid = resp.validPassword
                model.warning = resp.feedback.warning
                model.feedback = resp.feedback.suggestions.first ?? ""
            } catch {
                print(error)
            }
        }
    }

    private enum AuthOption: String, CaseIterable {
        case signUp = "Sign up"
        case logIn = "Log in"
    }

    private final class ViewModel: ObservableObject {
        @Published var password = ""
        @Published var authOption: AuthOption = .allCases.first!
        @Published var email = ""
        @Published var strength: Double?
        @Published var warning = ""
        @Published var feedback = ""
        @Published var isValid = false
        @Published var isSecure = false
        @Published var isLoading = false
    }
}
