import StytchCore
import StytchUI
import SwiftUI

struct AuthenticationOptionsView: View {
    let session: Session?
    let onAuth: (AuthenticateResponseType) -> Void
    @Environment(\.presentationMode) private var presentationMode
    @State private var authPresented = false

    var body: some View {
        VStack {
            Button("Authenticate with UI") {
                authPresented = true
            }
            .padding()

            NavigationLink("Authenticate with Email") { EmailAuthenticationView() }
                .padding()

            NavigationLink("Authenticate with Password") {
                PasswordAuthenticationView {
                    onAuth($0)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()

            if #available(iOS 16.0, macOS 13.0, *), session != nil {
                NavigationLink("Authenticate with Passkeys") {
                    PasskeysAuthenticationView {
                        onAuth($0)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                }
                .padding()
            }

            NavigationLink("Authenticate with OTP") {
                OTPAuthenticationView(session: session) {
                    onAuth($0)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()

            NavigationLink("Authenticate with OAuth") {
                OAuthAuthenticationView {
                    onAuth($0)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()

            if StytchClient.biometrics.registrationAvailable {
                Button("Authenticate with Biometrics") {
                    Task {
                        do {
                            onAuth(try await StytchClient.biometrics.authenticate(parameters: .init()))
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
                            onAuth(try await StytchClient.biometrics.register(parameters: .init(identifier: "")))
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            print(error)
                        }
                    }
                }
                .padding()
            }

            NavigationLink("Authenticate with TOTP") {
                TOTPAuthenticationView {
                    onAuth($0)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
        }
        .authenticationSheet(
            isPresented: $authPresented,
            config: .init(
                publicToken: configuration.publicToken,
                products: .init(
                    oauth: .init(
                        providers: [.apple, .thirdParty(.google)],
                        loginRedirectUrl: redirectUrl,
                        signupRedirectUrl: redirectUrl
                    ),
                    password: .init(
                        loginURL: redirectUrl,
                        resetPasswordURL: redirectUrl,
                        resetPasswordExpiration: 120
                    ),
                    magicLink: .init(
                        loginMagicLinkUrl: redirectUrl,
                        signupMagicLinkUrl: redirectUrl
                    ),
                    sms: .init()
                )
            )
        )
    }
}
