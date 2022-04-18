import StytchCore
import SwiftUI

struct LoginView: View {
    let hostUrl: URL

    @State private var email: String = ""
    @State private var isLoading = false

    var body: some View {
        VStack {
            TextField(text: $email, label: { Text("Email") })
                .padding()
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
            #if !os(macOS)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
            #endif

            Button(action: {
                isLoading = true
                Task {
                    let emailParams: EmailParameters = .init(
                        email: .init(rawValue: email),
                        loginMagicLinkUrl: hostUrl.appendingPathComponent("login"),
                        signupMagicLinkUrl: hostUrl.appendingPathComponent("signup"),
                        loginExpiration: .init(rawValue: 30),
                        signupExpiration: .init(rawValue: 30)
                    )
                    do {
                        _ = try await StytchClient.magicLinks.email.loginOrCreate(parameters: emailParams)
                    } catch {
                        print(error)
                    }
                    isLoading = false
                    // TODO: change screen to indicate the user should check their email
                }
            }, label: {
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
        }
    }
}
