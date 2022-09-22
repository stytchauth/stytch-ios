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

            NavigationLink("Authenticate with OAuth") {
                OAuthAuthenticationView {
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
                .padding()
            } else if session != nil {
                Button("Register Biometrics") {
                    Task {
                        do {
                            let resp = try await StytchClient.biometrics.register(parameters: .init(identifier: ""))
                            onAuth(resp.session, resp.user)
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            print(error)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct OAuthAuthenticationView: View {
    let onAuth: (Session, User) -> Void
    @Environment(\.presentationMode) private var presentationMode

    private var serverUrl: URL { configuration.serverUrl }

    var body: some View {
        Button("Authenticate with Apple") {
            Task {
                do {
                    let resp = try await StytchClient.oauth.apple.start()
                    onAuth(resp.session, resp.user)
                    presentationMode.wrappedValue.dismiss()
                } catch {
                    print(error)
                }
            }
        }
        .padding()

        Button("Authenticate with Google") {
            Task {
                do {
                    try await StytchClient.oauth.google.start(
                        parameters: .init(loginRedirectUrl: serverUrl, signupRedirectUrl: serverUrl)
                    )
                } catch {
                    print(error)
                }
            }
        }
        .padding()
    }
}
