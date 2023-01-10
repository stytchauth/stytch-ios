import StytchCore
import SwiftUI

struct TOTPAuthenticationView: View {
    let onAuth: (AuthenticateResponseType) -> Void

    @State private var secret: String = ""
    @State private var code: String = ""

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            if !secret.isEmpty {
                Text("Secret: " + secret).textSelection(.enabled)
            }

            Spacer()

            TextField("Code", text: $code)
                .textFieldStyle(.roundedBorder)
                .padding()

            Spacer()

            Button("Submit code") {
                Task {
                    do {
                        onAuth(try await StytchClient.totp.authenticate(parameters: .init(totpCode: code)))
                    } catch {
                        print(error)
                    }
                }
            }
            .disabled(code.isEmpty)
            .buttonStyle(.borderedProminent)

            Button("Generate new secret") {
                Task {
                    do {
                        let resp = try await StytchClient.totp.create(parameters: .init())
                        self.secret = resp.secret
                    } catch {
                        print(error)
                    }
                }
            }
            .buttonStyle(.bordered)
        }
    }
}
