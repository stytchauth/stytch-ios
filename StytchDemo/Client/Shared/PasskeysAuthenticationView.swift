import StytchCore
import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
struct PasskeysAuthenticationView: View {
    let onAuth: (AuthenticateResponseType) -> Void
    @Environment(\.presentationMode) private var presentationMode
    @State private var username: String = ""
    @State private var intent: Intent = .register

    private var domain: String {
        URLComponents(url: configuration.serverUrl, resolvingAgainstBaseURL: false)!.host!
    }

    var body: some View {
        Picker("Authenticate or register", selection: $intent) {
            ForEach(Intent.allCases, id: \.self) { intent in
                Text(intent.rawValue.capitalized).tag(intent)
            }
        }
        .pickerStyle(.segmented)

        switch intent {
        case .register:
            TextField("Username", text: $username)
                .textContentType(.username)
            #if os(iOS)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
            #endif
            Button("Register") {
                Task {
                    do {
                        let components = URLComponents(url: configuration.serverUrl, resolvingAgainstBaseURL: false)!
                        _ = try await StytchClient.passkeys.register(parameters: .init(domain: components.host!, username: username))
                        presentationMode.wrappedValue.dismiss()
                    } catch {
                        print(error)
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        case .authenticate:
            Button("Authenticate") {
                Task {
                    do {
                        onAuth(try await StytchClient.passkeys.authenticate(parameters: .init(domain: domain)))
                    } catch {
                        print(error)
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

@available(iOS 16.0, macOS 13.0, *)
extension PasskeysAuthenticationView {
    private enum Intent: String, CaseIterable {
        case authenticate
        case register
    }
}
