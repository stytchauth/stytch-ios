import StytchCore
import SwiftUI

struct LoginView: View {
    let hostUrl: URL

    @State private var email: String = ""
    @State private var isLoading = false
    @State private var checkEmailPresented = false

    var body: some View {
        VStack {
            TextField(text: $email, label: { Text("Email") })
                .onSubmit(login)
                .padding()
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
            #if !os(macOS)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
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
        .alert("🪄 Check your email to finish logging in. 🪄", isPresented: $checkEmailPresented, actions: { EmptyView() })
    }

    func login() {
        isLoading = true
        Task {
            let emailParams: StytchClient.MagicLinks.Email.Parameters = .init(
                email: email,
                loginMagicLinkUrl: hostUrl.appendingPathComponent("login"),
                signupMagicLinkUrl: hostUrl.appendingPathComponent("signup"),
                loginExpiration: 10,
                signupExpiration: 10
            )
            do {
                _ = try await StytchClient.magicLinks.email.loginOrCreate(parameters: emailParams)
                checkEmailPresented = true
            } catch {
                print(error)
            }
            isLoading = false
        }
    }
}

struct SMSLoginView: View {
    let hostUrl: URL
    let onAuth: (Session) -> Void

    @State private var phoneNumber: String = ""
    @State private var isLoading = false
    @State private var methodId = ""
    @State private var otp = ""
//    @State private var checkEmailPresented = false

    var body: some View {
        VStack {
            if methodId.isEmpty {
                TextField(text: $phoneNumber, label: { Text("Phone Number") })
                    .onSubmit(login)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
                #if !os(macOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                #endif
            } else {
                TextField(text: $otp, label: { Text("One-time Code") })
                    .onSubmit(authenticate)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
                #if !os(macOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.phonePad)
                    .textContentType(.oneTimeCode)
                #endif
            }

            Button(action: methodId.isEmpty ? login : authenticate, label: {
                if isLoading {
                    ZStack {
                        ProgressView()
                            .progressViewStyle(.circular)
                        Text("Log in").hidden()
                    }
                } else {
                    Text(methodId.isEmpty ? "Log in" : "Submit Code")
                }
            })
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || phoneNumber.isEmpty)
            .padding()
        }
//        .alert("🪄 Check your email to finish logging in. 🪄", isPresented: $checkEmailPresented, actions: { EmptyView() })
    }

    func login() {
        isLoading = true
        Task {
            let otpParams: StytchClient.OneTimePasscodes.LoginOrCreateParameters = .init(
                deliveryMethod: .sms(phoneNumber: "+1" + phoneNumber.filter(\.isNumber))
            )
            do {
                let response = try await StytchClient.otps.loginOrCreate(parameters: otpParams)
                methodId = response.methodId
            } catch {
                print(error)
            }
            isLoading = false
        }
    }

    func authenticate() {
        isLoading = true
        Task {
            let params: StytchClient.OneTimePasscodes.AuthenticateParameters = .init(code: otp, methodId: methodId, sessionDuration: 30)
            do {
                let sessionResp = try await StytchClient.otps.authenticate(parameters: params)
                onAuth(sessionResp.session)
            } catch {
                print(error)
            }
            isLoading = false
        }
    }
}
