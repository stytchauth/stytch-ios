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
                        onAuth(try await StytchClient.totps.authenticate(parameters: .init(totpCode: code)))
                    } catch {
                        print(error.errorInfo)
                    }
                }
            }
            .disabled(code.isEmpty)
            .buttonStyle(.borderedProminent)

            Button("Generate new secret") {
                Task {
                    do {
                        let resp = try await StytchClient.totps.create(parameters: .init())
                        self.secret = resp.secret
                    } catch {
                        print(error.errorInfo)
                    }
                }
            }
            .buttonStyle(.bordered)
        }
    }
}
