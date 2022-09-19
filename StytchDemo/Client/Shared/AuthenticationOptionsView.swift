import StytchCore
import SwiftUI

struct AuthenticationOptionsView: View {
    let session: Session?
    let onAuth: (Session, User) -> Void
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack {
            NavigationLink("Authenticate with Email") { EmailAuthenticationView() }
                .padding()
            NavigationLink("Authenticate with Password") {
                PasswordAuthenticationView {
                    onAuth($0, $1)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
            NavigationLink("Authenticate with OTP") {
                OTPAuthenticationView(session: session) {
                    onAuth($0, $1)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()

            if StytchClient.biometrics.registrationAvailable {
                Button("Authenticate with Biometrics") {
                    Task {
                        do {
                            let resp = try await StytchClient.biometrics.authenticate(parameters: .init())
                            onAuth(resp.session, resp.user)
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            print(error)
                        }
                    }
                }
            } else if
                let session = session,
                case let .email(email) = session.authenticationFactors.first(where: { if case .email = $0.deliveryMethod { return true } else { return false } })?.deliveryMethod
            {
                Button("Register Biometrics") {
                    Task {
                        do {
                            let resp = try await StytchClient.biometrics.register(parameters: .init(identifier: email.emailAddress))
                            onAuth(resp.session, resp.user)
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }
    }
}
