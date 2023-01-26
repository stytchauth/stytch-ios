import StytchCore
import SwiftUI

struct OTPAuthenticationView: View {
    let session: Session?
    let onAuth: (AuthenticateResponseType) -> Void

    @State private var deliveryMethod: DeliveryMethod = .sms
    @State private var deliveryMethodValue: String = ""
    @State private var loginTemplateId: String = ""
    @State private var signupTemplateId: String = ""
    @State private var isLoading = false
    @State private var methodId = ""
    @State private var otp = ""

    enum DeliveryMethod: String, Hashable, CaseIterable {
        case sms
        case whatsapp
        case email

        var title: String {
            switch self {
            case .sms: return "SMS"
            case .whatsapp: return "WhatsApp"
            case .email: return "Email"
            }
        }

        var label: String {
            switch self {
            case .sms, .whatsapp: return "Phone Number"
            case .email: return "Email"
            }
        }

        #if !os(macOS)
        var contentType: UITextContentType {
            switch self {
            case .sms, .whatsapp: return .telephoneNumber
            case .email: return .emailAddress
            }
        }

        var keyboardType: UIKeyboardType {
            switch self {
            case .sms, .whatsapp: return .phonePad
            case .email: return .emailAddress
            }
        }
        #endif

        func deliveryMethod(_ value: String, loginTemplateId: String?, signupTemplateId: String?) -> StytchClient.OneTimePasscodes.DeliveryMethod {
            let normalizedPhone: () -> String = { "+1" + value.filter(\.isNumber) }
            switch self {
            case .whatsapp:
                return .whatsapp(phoneNumber: normalizedPhone())
            case .sms:
                return .sms(phoneNumber: normalizedPhone())
            case .email:
                return .email(email: value, loginTemplateId: loginTemplateId.presence, signupTemplateId: signupTemplateId.presence)
            }
        }
    }

    var body: some View {
        VStack {
            Picker(
                selection: $deliveryMethod,
                content: {
                    ForEach(DeliveryMethod.allCases, id: \.self) { Text($0.title).tag($0) }
                },
                label: { Text("Delivery Method") }
            )
            .pickerStyle(.segmented)
            .padding()

            Spacer()

            if methodId.isEmpty {
                TextField(deliveryMethod.label, text: $deliveryMethodValue)
                    .onSubmit(login)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
                #if !os(macOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(deliveryMethod.keyboardType)
                    .textContentType(deliveryMethod.contentType)
                #endif

                if deliveryMethod == .email {
                    TextField("Signup template ID", text: $signupTemplateId)
                        .onSubmit(login)
                        .padding()
                        .textFieldStyle(.roundedBorder)
                        .disableAutocorrection(true)
                    #if !os(macOS)
                        .textInputAutocapitalization(.never)
                    #endif

                    TextField("Login template ID", text: $loginTemplateId)
                        .onSubmit(login)
                        .padding()
                        .textFieldStyle(.roundedBorder)
                        .disableAutocorrection(true)
                    #if !os(macOS)
                        .textInputAutocapitalization(.never)
                    #endif
                }
            } else {
                TextField(text: $otp, label: { Text("One-time Code") })
                    .onSubmit(authenticate)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
                #if os(macOS)
                    .textContentType(.oneTimeCode)
                #else
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
                        Text("Authenticate").hidden()
                    }
                } else {
                    Text(methodId.isEmpty ? "Authenticate" : "Submit Code")
                }
            })
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || deliveryMethodHasRecentAuth || deliveryMethodValue.isEmpty)
            .padding()

            Spacer()
        }
    }

    var deliveryMethodHasRecentAuth: Bool {
        guard let session = session else {
            return false
        }

        // If the delivery method has authenticated in the last 3 minutes, it has recent auth
        return session.authenticationFactors
            .filter { $0.kind == "otp" }
            .contains {
                $0.lastAuthenticatedAt > Date().addingTimeInterval(-180)
            }
    }

    func login() {
        isLoading = true
        Task {
            let otpParams: StytchClient.OneTimePasscodes.Parameters = .init(
                deliveryMethod: deliveryMethod.deliveryMethod(
                    deliveryMethodValue,
                    loginTemplateId: loginTemplateId.presence,
                    signupTemplateId: signupTemplateId.presence
                )
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
                onAuth(try await StytchClient.otps.authenticate(parameters: params))
            } catch {
                print(error)
            }
            isLoading = false
        }
    }
}
